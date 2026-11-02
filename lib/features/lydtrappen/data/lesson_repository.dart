import 'dart:convert';

import '../../audio/spoken_word.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VowelLadder {
  const VowelLadder(this.id, this.label, this.letters);
  final String id, label;
  final List<String> letters;
}

class WordEntry implements SpokenWord {
  const WordEntry({
    required this.id,
    required this.text,
    required this.ladderId,
    required this.spellingVowel,
    required this.pronunciationHint,
    required this.patternId,
    required this.explanation,
    required this.contentStatus,
    required this.ttsText,
    required this.locale,
    this.assetPath,
  });
  final String id,
      ladderId,
      spellingVowel,
      pronunciationHint,
      patternId,
      explanation,
      contentStatus;
  @override
  final String text;
  @override
  final String ttsText;
  @override
  final String locale;
  @override
  final String? assetPath;
}

class Exercise {
  const Exercise(
    this.id,
    this.wordId,
    this.maskedText,
    this.options,
    this.answer,
  );
  final String id, wordId, maskedText, answer;
  final List<String> options;
  bool accepts(String value) => value == answer;
}

class LessonContent {
  const LessonContent(
    this.ladders,
    this.words,
    this.exercises, {
    this.approvedAssets = const {},
  });
  final List<VowelLadder> ladders;
  final List<WordEntry> words;
  final List<Exercise> exercises;
  final Set<String> approvedAssets;
  WordEntry word(String id) => words.firstWhere((w) => w.id == id);
  List<Exercise> forLadder(String id) =>
      exercises.where((e) => word(e.wordId).ladderId == id).toList();
}

class ContentValidator {
  static LessonContent parse(Map<String, dynamic> data) {
    Never fail(String code) => throw FormatException(code);
    String text(Map<String, dynamic> m, String key) {
      final value = m[key];
      if (value is! String || value.trim().isEmpty) fail('missing_field:$key');
      return value;
    }

    List<Map<String, dynamic>> rows(String key) {
      final value = data[key];
      if (value is! List ||
          value.isEmpty ||
          value.any((v) => v is! Map<String, dynamic>)) {
        fail('invalid_list:$key');
      }
      return value.cast<Map<String, dynamic>>();
    }

    List<String> strings(Object? value) {
      if (value is! List ||
          value.isEmpty ||
          value.any((v) => v is! String || v.isEmpty)) {
        fail('invalid_options');
      }
      return value.cast<String>();
    }

    if (data['schemaVersion'] != 1) fail('schema_version');
    if (text(data, 'moduleId') != 'lydtrappe.vokaler') fail('module_id');
    text(data, 'title');
    if (data['targetGrades'] is! List ||
        (data['targetGrades'] as List).isEmpty ||
        (data['targetGrades'] as List).any(
          (v) => v is! int || v < 1 || v > 9,
        )) {
      fail('target_grades');
    }
    final ladders = rows('ladders')
        .map(
          (m) => VowelLadder(
            text(m, 'id'),
            text(m, 'label'),
            strings(m['letters']),
          ),
        )
        .toList();
    final words = rows('words').map((m) {
      final a = m['audio'];
      if (a is! Map<String, dynamic>) fail('missing_audio');
      final path = a['assetPath'];
      if (path != null &&
          (path is! String ||
              !path.startsWith('assets/audio/') ||
              path.contains('..') ||
              path.contains(r'\'))) {
        fail('invalid_asset_path');
      }
      final status = text(m, 'contentStatus');
      if (!['draft', 'approved'].contains(status)) fail('content_status');
      if (text(a, 'locale') != 'da-DK') fail('audio_locale');
      if (text(a, 'ttsText') != text(m, 'text')) fail('tts_must_be_whole_word');
      return WordEntry(
        id: text(m, 'id'),
        text: text(m, 'text'),
        ladderId: text(m, 'ladderId'),
        spellingVowel: text(m, 'spellingVowel'),
        pronunciationHint: text(m, 'pronunciationHint'),
        patternId: text(m, 'patternId'),
        explanation: text(m, 'explanation'),
        contentStatus: status,
        assetPath: path as String?,
        ttsText: text(a, 'ttsText'),
        locale: text(a, 'locale'),
      );
    }).toList();
    final exercises = rows('exercises').map((m) {
      if (m['type'] != 'choose_missing_vowel') fail('exercise_type');
      return Exercise(
        text(m, 'id'),
        text(m, 'wordId'),
        text(m, 'maskedText'),
        strings(m['options']),
        text(m, 'answer'),
      );
    }).toList();
    void ids(Iterable<String> values, String kind) {
      final list = values.toList();
      if (list.toSet().length != list.length) fail('duplicate_id:$kind');
      if (list.any((v) => !RegExp(r'^[a-z0-9-]+$').hasMatch(v))) {
        fail('invalid_id:$kind');
      }
    }

    ids(ladders.map((x) => x.id), 'ladder');
    ids(words.map((x) => x.id), 'word');
    ids(exercises.map((x) => x.id), 'exercise');
    for (final w in words) {
      if (!ladders.any((l) => l.id == w.ladderId)) {
        fail('unknown_ladder:${w.id}');
      }
      final l = ladders.firstWhere((l) => l.id == w.ladderId);
      const transitions = {
        'i': ['e', 'æ'],
        'e': ['æ', 'a'],
        'æ': ['a'],
        'u': ['å'],
        'o': ['å'],
        'y': ['ø'],
      };
      if (!(transitions[w.spellingVowel]?.contains(w.pronunciationHint) ??
          false)) {
        fail('unsupported_vowel_pattern:${w.id}');
      }

      if (w.spellingVowel.length != 1 ||
          !l.letters.contains(w.spellingVowel) ||
          !w.text.contains(w.spellingVowel)) {
        fail('spelling_vowel:${w.id}');
      }
    }
    for (final e in exercises) {
      if (!words.any((w) => w.id == e.wordId)) fail('unknown_word:${e.id}');
      final w = words.firstWhere((w) => w.id == e.wordId);
      if (e.options.toSet().length != e.options.length ||
          e.options.length < 2 ||
          e.options.any((v) => !RegExp(r'^[aeiouyæøå]$').hasMatch(v)) ||
          !e.options.contains(e.answer)) {
        fail('options:${e.id}');
      }
      if ('_'.allMatches(e.maskedText).length != 1 ||
          e.maskedText.replaceFirst('_', e.answer) != w.text ||
          e.answer != w.spellingVowel) {
        fail('masked_word:${e.id}');
      }
    }
    return LessonContent(ladders, words, exercises);
  }
}

class LessonRepository {
  Future<LessonContent> load({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    try {
      final data = ContentValidator.parse(
        jsonDecode(await assets.loadString('assets/data/vowel_ladders_v1.json'))
            as Map<String, dynamic>,
      );
      final manifest = jsonDecode(
        await assets.loadString('assets/audio/audio_manifest.json'),
      ) as Map<String, dynamic>;
      if (manifest['schemaVersion'] != 1 || manifest['clips'] is! List) {
        throw const FormatException('audio_manifest');
      }
      final approved = <String>{};
      for (final clip in manifest['clips'] as List) {
        if (clip is! Map<String, dynamic>) {
          throw const FormatException('audio_clip');
        }
        final path = clip['assetPath'];
        if (path is! String ||
            !path.startsWith('assets/audio/') ||
            path.contains('..')) {
          throw const FormatException('audio_path');
        }
        await assets.load(path);
        if (clip['kind'] == 'spoken_word' &&
            clip['locale'] == 'da-DK' &&
            clip['audioReviewStatus'] == 'approved' &&
            clip['pedagogicalReviewStatus'] == 'approved' &&
            (clip['licenseId'] as String? ?? '').isNotEmpty &&
            (clip['licenseEvidence'] as String? ?? '').isNotEmpty &&
            data.words.any(
              (w) => w.id == clip['wordId'] && w.assetPath == path,
            )) {
          approved.add(path);
        }
      }
      for (final w in data.words) {
        if (w.assetPath != null) await assets.load(w.assetPath!);
      }
      return LessonContent(
        data.ladders,
        data.words,
        data.exercises,
        approvedAssets: approved,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Content load failed: $e');
      rethrow;
    }
  }
}
