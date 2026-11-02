import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesProgressStore implements ProgressStore {
  final _preferences = SharedPreferencesAsync();
  // Keep the established key so existing installations migrate in place.
  @override
  Future<String?> read() => _preferences.getString('progress_v1');
  @override
  Future<void> write(String value) =>
      _preferences.setString('progress_v1', value);
}

enum PracticeLevel { supported, independent }

class ResumePosition {
  const ResumePosition(
    this.modulePath,
    this.lessonId,
    this.exerciseId, {
    this.correct,
  });
  final String modulePath, lessonId, exerciseId;
  final bool? correct;
  Map<String, Object?> toJson() => {
    'modulePath': modulePath,
    'lessonId': lessonId,
    'exerciseId': exerciseId,
    'correct': correct,
  };
  static ResumePosition? parse(Object? raw, Set<String> knownIds) {
    if (raw is! Map<String, dynamic>) return null;
    final path = raw['modulePath'],
        lesson = raw['lessonId'],
        exercise = raw['exerciseId'],
        correct = raw['correct'];
    if (path is! String ||
        ![
          '/lydtrappe/vokaler',
          '/stavelser',
          '/ordstruktur',
          '/udsagnsord',
        ].contains(path) ||
        lesson is! String ||
        !RegExp(r'^[a-z0-9-]+$').hasMatch(lesson) ||
        exercise is! String ||
        !knownIds.contains(exercise) ||
        (correct != null && correct is! bool)) {
      return null;
    }
    return ResumePosition(path, lesson, exercise, correct: correct as bool?);
  }
}

class ExerciseStats {
  ExerciseStats({
    this.totalAttempts = 0,
    this.firstAttemptCorrect = false,
    this.lastCompletedAt,
    this.lastAttemptAt,
    this.lastAttemptCorrect,
    this.reviewNeeded = false,
  });
  int totalAttempts;
  bool firstAttemptCorrect, reviewNeeded;
  DateTime? lastCompletedAt, lastAttemptAt;
  bool? lastAttemptCorrect;
  bool get completed => lastCompletedAt != null;
}

class ProgressRepository extends ChangeNotifier {
  ProgressRepository(this.store);
  final ProgressStore store;
  final Map<String, ExerciseStats> stats = {};
  PracticeLevel level = PracticeLevel.supported;
  ResumePosition? resume;
  String profileId = 'local-default';
  Map<String, dynamic> _profiles = {};
  String? warning;
  bool _disposed = false;
  Future<void> _writes = Future.value();
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> flush() => _writes;
  Future<void> load(Set<String> knownIds) async {
    stats.clear();
    resume = null;
    level = PracticeLevel.supported;
    profileId = 'local-default';
    _profiles = {};
    warning = null;
    try {
      final raw = await store.read();
      if (raw == null) return;
      final document = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, dynamic> data;
      if (document['schemaVersion'] == 1) {
        data = document;
      } else if (document['schemaVersion'] == 2) {
        final profiles = document['profiles'],
            active = document['activeProfileId'];
        if (profiles is! Map<String, dynamic> ||
            active is! String ||
            !RegExp(r'^[a-z0-9-]+$').hasMatch(active) ||
            profiles[active] is! Map<String, dynamic>) {
          throw const FormatException('progress_profiles');
        }
        _profiles = Map.of(profiles);
        profileId = active;
        data = profiles[active] as Map<String, dynamic>;
      } else {
        throw const FormatException('progress_schema');
      }
      level = data['level'] == 'independent'
          ? PracticeLevel.independent
          : PracticeLevel.supported;
      resume = ResumePosition.parse(data['resume'], knownIds);
      final rows = data['exerciseStats'] as Map<String, dynamic>;
      for (final entry in rows.entries) {
        if (!knownIds.contains(entry.key)) continue;
        final m = entry.value as Map<String, dynamic>;
        final attempts = m['totalAttempts'], first = m['firstAttemptCorrect'];
        DateTime? date(Object? raw) {
          if (raw == null) return null;
          if (raw is! String) throw const FormatException('progress_date');
          final value = DateTime.tryParse(raw);
          if (value == null || value.isAfter(DateTime.now().toUtc())) {
            throw const FormatException('progress_date');
          }
          return value;
        }

        final completed = date(m['lastCompletedAt']),
            lastAttempt = date(m['lastAttemptAt']);
        final lastCorrect = m['lastAttemptCorrect'];
        final review = m['reviewNeeded'];
        if (attempts is! int ||
            attempts < 0 ||
            first is! bool ||
            (completed != null && attempts == 0) ||
            (lastCorrect != null && lastCorrect is! bool) ||
            (review != null && review is! bool)) {
          throw const FormatException('progress_stats');
        }
        stats[entry.key] = ExerciseStats(
          totalAttempts: attempts,
          firstAttemptCorrect: first,
          lastCompletedAt: completed,
          lastAttemptAt: lastAttempt,
          lastAttemptCorrect: lastCorrect as bool?,
          reviewNeeded: review as bool? ?? (attempts > 0 && !first),
        );
      }
    } catch (e) {
      stats.clear();
      resume = null;
      level = PracticeLevel.supported;
      _profiles = {};
      profileId = 'local-default';
      warning = 'Fremskridt kunne ikke indlæses. Du kan stadig øve dig.';
      if (kDebugMode) debugPrint('Progress load failed: $e');
    }
    _changed();
  }

  Future<void> record(String id, bool correct) {
    final s = stats.putIfAbsent(id, () => ExerciseStats());
    final previouslyCompleted = s.completed;
    if (s.totalAttempts == 0) s.firstAttemptCorrect = correct;
    if (!correct) {
      s.reviewNeeded = true;
    } else if (previouslyCompleted && s.lastAttemptCorrect != false) {
      s.reviewNeeded = false;
    }
    s.totalAttempts++;
    s.lastAttemptCorrect = correct;
    s.lastAttemptAt = DateTime.now().toUtc();
    if (correct) s.lastCompletedAt = s.lastAttemptAt;
    _changed();
    return _save();
  }

  Future<void> setLevel(PracticeLevel value) {
    level = value;
    _changed();
    return _save();
  }

  Future<void> setResume(ResumePosition? value) {
    resume = value;
    _changed();
    return _save();
  }

  Future<void> clearResumeFor(String path, String lessonId) {
    if (resume?.modulePath == path && resume?.lessonId == lessonId) {
      return setResume(null);
    }
    return Future.value();
  }

  Future<void> reset() {
    stats.clear();
    resume = null;
    level = PracticeLevel.supported;
    _changed();
    return _save();
  }

  Future<void> _save() {
    _profiles[profileId] = {
      'level': level.name,
      'resume': resume?.toJson(),
      'completedExerciseIds': stats.entries
          .where((e) => e.value.completed)
          .map((e) => e.key)
          .toList(),
      'exerciseStats': stats.map(
        (id, s) => MapEntry(id, {
          'totalAttempts': s.totalAttempts,
          'firstAttemptCorrect': s.firstAttemptCorrect,
          'lastCompletedAt': s.lastCompletedAt?.toIso8601String(),
          'lastAttemptAt': s.lastAttemptAt?.toIso8601String(),
          'lastAttemptCorrect': s.lastAttemptCorrect,
          'reviewNeeded': s.reviewNeeded,
        }),
      ),
    };
    final encoded = jsonEncode({
      'schemaVersion': 2,
      'activeProfileId': profileId,
      'profiles': _profiles,
    });
    _writes = _writes.then((_) async {
      try {
        await store.write(encoded);
        warning = null;
      } catch (e) {
        warning = 'Fremskridt gemmes kun, mens appen er åben.';
        if (kDebugMode) debugPrint('Progress save failed: $e');
      }
      _changed();
    });
    return _writes;
  }
}
