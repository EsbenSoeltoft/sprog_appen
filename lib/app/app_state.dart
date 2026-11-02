import '../features/audio/learning_audio_service.dart';
import '../features/udsagnsord/verb_repository.dart';
import '../features/stavelser_endelser/data/syllable_repository.dart';
import '../features/lydtrappen/data/lesson_repository.dart';
import '../features/lydtrappen/logic/exercise_controller.dart';
import '../features/progress/progress_repository.dart';

class PracticeTarget {
  const PracticeTarget(
    this.modulePath,
    this.lessonId,
    this.exerciseId,
    this.title,
  );
  final String modulePath, lessonId, exerciseId, title;
}

class AppState {
  AppState(
    this.content,
    this.progress,
    this.audio, {
    this.syllables,
    this.wordStructure,
    this.verbs,
  });
  final SyllableContent? syllables, wordStructure;
  final VerbContent? verbs;
  final LessonContent content;
  final ProgressRepository progress;
  final LearningAudioService audio;
  final Map<String, ExerciseController> _sessions = {};
  SyllableContent? practiceContent(String path) => switch (path) {
    '/udsagnsord' => verbs?.practice,
    '/ordstruktur' => wordStructure,
    '/stavelser' => syllables,
    _ => null,
  };
  List<PracticeTarget> get targets => [
    for (final ladder in content.ladders)
      for (final e in content.forLadder(ladder.id))
        PracticeTarget(
          '/lydtrappe/vokaler',
          ladder.id,
          e.id,
          'Vokaltrappen · ${ladder.label}',
        ),
    for (final path in ['/stavelser', '/ordstruktur', '/udsagnsord'])
      for (final lesson in practiceContent(path)?.lessons ?? <SyllableLesson>[])
        for (final id in lesson.exerciseIds)
          PracticeTarget(path, lesson.id, id, lesson.title),
  ];
  PracticeTarget? get resumeTarget {
    final r = progress.resume;
    if (r == null) return null;
    for (final t in targets) {
      if (t.modulePath == r.modulePath &&
          t.lessonId == r.lessonId &&
          t.exerciseId == r.exerciseId) {
        return t;
      }
    }
    return null;
  }

  PracticeTarget? get recommendation {
    final all = targets;
    final review = all
        .where((t) => progress.stats[t.exerciseId]?.reviewNeeded ?? false)
        .toList();
    if (review.isNotEmpty) {
      review.sort(
        (a, b) =>
            (progress.stats[a.exerciseId]!.lastAttemptAt ?? DateTime(1970))
                .compareTo(
                  progress.stats[b.exerciseId]!.lastAttemptAt ?? DateTime(1970),
                ),
      );
      return review.first;
    }
    for (final t in all) {
      if (!(progress.stats[t.exerciseId]?.completed ?? false)) return t;
    }
    if (all.isEmpty) return null;
    all.sort(
      (a, b) => progress.stats[a.exerciseId]!.lastCompletedAt!.compareTo(
        progress.stats[b.exerciseId]!.lastCompletedAt!,
      ),
    );
    return all.first;
  }

  String recommendationReason(PracticeTarget target) {
    final s = progress.stats[target.exerciseId];
    if (s?.reviewNeeded ?? false) {
      return 'Denne opgave kan være god at gentage. Prøv den igen i dit eget tempo.';
    }
    if (!(s?.completed ?? false)) {
      return 'Her er en opgave, du endnu ikke har gennemført.';
    }
    return 'Gentag en tidligere opgave, når du har lyst.';
  }

  int get completedLessons {
    final groups = <String, List<PracticeTarget>>{};
    for (final t in targets) {
      groups.putIfAbsent('${t.modulePath}/${t.lessonId}', () => []).add(t);
    }
    return groups.values
        .where(
          (tasks) => tasks.every(
            (t) => progress.stats[t.exerciseId]?.completed ?? false,
          ),
        )
        .length;
  }

  bool? _savedOutcome(ResumePosition position) {
    final last = progress.stats[position.exerciseId]?.lastAttemptCorrect;
    return position.correct != null && position.correct == last ? last : null;
  }

  ExerciseController _session(
    String path,
    String id,
    List<Exercise> exercises,
  ) => _sessions.putIfAbsent(id, () {
    final controller = ExerciseController(
      exercises,
      progress,
      onPosition: (e, correct) => e == null
          ? progress.clearResumeFor(path, id)
          : progress.setResume(
              ResumePosition(path, id, e.id, correct: correct),
            ),
    );
    final r = progress.resume;
    if (r != null && r.modulePath == path && r.lessonId == id) {
      final index = exercises.indexWhere((e) => e.id == r.exerciseId);
      if (index >= 0) {
        controller.index = index;
        controller.correct = _savedOutcome(r);
      }
    }
    return controller;
  });
  ExerciseController practiceSession(String path, String id) =>
      _session(path, id, practiceContent(path)!.forLesson(id));
  ExerciseController session(String id) =>
      _session('/lydtrappe/vokaler', id, content.forLadder(id));
  ExerciseController syllableSession(String id) =>
      practiceSession('/stavelser', id);
  String openTarget(PracticeTarget target, {bool resume = false}) {
    final s = target.modulePath == '/lydtrappe/vokaler'
        ? session(target.lessonId)
        : practiceSession(target.modulePath, target.lessonId);
    s.index = s.exercises.indexWhere((e) => e.id == target.exerciseId);
    s.finished = false;
    s.correct = resume && progress.resume != null
        ? _savedOutcome(progress.resume!)
        : null;
    return target.modulePath == '/lydtrappe/vokaler'
        ? '/lydtrappe/oevelse/${target.exerciseId}'
        : '${target.modulePath}/${target.lessonId}/oevelse';
  }

  void dispose() {
    for (final s in _sessions.values) {
      s.dispose();
    }
    progress.dispose();
  }
}
