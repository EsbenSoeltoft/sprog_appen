import 'dart:convert';

import 'package:flutter/services.dart';

import '../../audio/spoken_word.dart';
import '../../lydtrappen/data/lesson_repository.dart';

class SyllableWord implements SpokenWord {
  const SyllableWord({
    required this.id,
    required this.text,
    required this.syllables,
    required this.explanation,
    required this.contentStatus,
    required this.ttsText,
    required this.locale,
    this.stem,
    this.ending,
    this.context,
    this.parts = const [],
    this.linkingElement = '',
    this.lineBreaks = const [],
  });
  final String id;
  @override
  final String text;
  final List<String> syllables;
  final List<String> parts, lineBreaks;
  final String linkingElement;
  final String explanation, contentStatus;
  final String? stem, ending, context;
  @override
  final String ttsText, locale;
  // V2 segment recordings remain pending; no fabricated asset references.
  @override
  String? get assetPath => null;
}

class SyllableLesson {
  const SyllableLesson(this.id, this.title, this.description, this.exerciseIds);
  final String id, title, description;
  final List<String> exerciseIds;
}

class SyllableTask {
  const SyllableTask(this.exercise, this.type, this.prompt, this.tiles);
  final Exercise exercise;
  final String type, prompt;
  final List<String> tiles;
}

class SyllableContent {
  const SyllableContent(this.lessons, this.words, this.tasks);
  final List<SyllableLesson> lessons;
  final List<SyllableWord> words;
  final List<SyllableTask> tasks;
  SyllableWord word(String id) => words.firstWhere((w) => w.id == id);
  SyllableTask task(String id) => tasks.firstWhere((t) => t.exercise.id == id);
  List<Exercise> forLesson(String id) => lessons
      .firstWhere((l) => l.id == id)
      .exerciseIds
      .map((id) => task(id).exercise)
      .toList();
  Set<String> get exerciseIds => tasks.map((t) => t.exercise.id).toSet();
}

class SyllableValidator {
  static SyllableContent parse(
    Map<String, dynamic> data, {
    String moduleId = 'stavelser-endelser',
  }) {
    final v3 = moduleId == 'ordstruktur';
    Never fail(String code) =>
        throw FormatException('${v3 ? 'v3' : 'v2'}:$code');
    String text(Map<String, dynamic> m, String key) {
      final v = m[key];
      if (v is! String || v.trim().isEmpty) fail('missing:$key');
      return v;
    }

    List<String> strings(Object? v) {
      if (v is! List || v.isEmpty || v.any((e) => e is! String || e.isEmpty)) {
        fail('invalid_list');
      }
      return v.cast<String>();
    }

    List<Map<String, dynamic>> rows(String key) {
      final v = data[key];
      if (v is! List || v.isEmpty || v.any((e) => e is! Map<String, dynamic>)) {
        fail('invalid:$key');
      }
      return v.cast<Map<String, dynamic>>();
    }

    if (data['schemaVersion'] != 1 || data['moduleId'] != moduleId) {
      fail('schema');
    }
    text(data, 'title');
    final lessons = rows('lessons')
        .map(
          (m) => SyllableLesson(
            text(m, 'id'),
            text(m, 'title'),
            text(m, 'description'),
            strings(m['exerciseIds']),
          ),
        )
        .toList();
    final words = rows('words').map((m) {
      final a = m['audio'];
      if (a is! Map<String, dynamic>) fail('audio');
      final word = text(m, 'text');
      final syllables = m['syllables'] == null
          ? <String>[]
          : strings(m['syllables']);
      if (syllables.isNotEmpty &&
          (syllables.length < 2 ||
              syllables.join() != word ||
              syllables.any((s) => !RegExp('[aeiouyæøå]').hasMatch(s)))) {
        fail('syllables');
      }
      final parts = m['parts'] == null ? <String>[] : strings(m['parts']);
      final breaks = m['lineBreaks'] == null
          ? <String>[]
          : strings(m['lineBreaks']);
      final link = m['linkingElement'] ?? '';
      if (link is! String || !['', 's', 'e'].contains(link)) {
        fail('linking_element');
      }
      if (parts.isNotEmpty &&
          (parts.length != 2 || parts[0] + link + parts[1] != word)) {
        fail('compound_parts');
      }
      if (parts.isEmpty && link.isNotEmpty) fail('link_without_parts');
      for (final split in breaks) {
        final lines = split.split('-');
        if (lines.length != 2 ||
            lines.join() != word ||
            lines.any((l) => !RegExp('[aeiouyæøå]').hasMatch(l))) {
          fail('line_break');
        }
      }
      if (!v3 && (parts.isNotEmpty || breaks.isNotEmpty)) fail('module_fields');
      final status = text(m, 'contentStatus');
      if (!['draft', 'approved'].contains(status)) fail('status');
      if (a['assetPath'] != null ||
          a['locale'] != 'da-DK' ||
          a['ttsText'] != word) {
        fail('whole_word_audio');
      }
      final stem = m['stem'], ending = m['ending'], context = m['context'];
      if (stem != null || ending != null || context != null) {
        if (stem is! String ||
            stem.isEmpty ||
            ending is! String ||
            ending.isEmpty ||
            stem + ending != word ||
            context is! String ||
            '_'.allMatches(context).length != 1 ||
            !context.contains('${stem}_')) {
          fail('ending_context');
        }
      }
      return SyllableWord(
        id: text(m, 'id'),
        text: word,
        syllables: syllables,
        explanation: text(m, 'explanation'),
        contentStatus: status,
        ttsText: word,
        locale: 'da-DK',
        stem: stem as String?,
        ending: ending as String?,
        context: context as String?,
        parts: parts,
        linkingElement: link,
        lineBreaks: breaks,
      );
    }).toList();
    final tasks = rows('exercises').map((m) {
      final type = text(m, 'type');
      if (!(v3
              ? [
                  'choose_syllables',
                  'build_compound',
                  'choose_parts',
                  'choose_line_break',
                ]
              : ['choose_syllables', 'build_word', 'choose_ending'])
          .contains(type)) {
        fail('type');
      }
      final options = strings(m['options']);
      final answer = text(m, 'answer');
      if (options.length < 2 ||
          options.toSet().length != options.length ||
          !options.contains(answer)) {
        fail('options');
      }
      final e = Exercise(text(m, 'id'), text(m, 'wordId'), '', options, answer);
      return SyllableTask(
        e,
        type,
        text(m, 'prompt'),
        ['build_word', 'build_compound'].contains(type)
            ? strings(m['tiles'])
            : const [],
      );
    }).toList();
    void ids(Iterable<String> ids) {
      final list = ids.toList();
      if (list.toSet().length != list.length ||
          list.any(
            (id) =>
                !RegExp(v3 ? r'^v3-[a-z0-9-]+$' : r'^v2-[a-z0-9-]+$')
                    .hasMatch(id),
          )) {
        fail('duplicate_or_invalid_id');
      }
    }

    ids(lessons.map((l) => l.id));
    ids(words.map((w) => w.id));
    ids(tasks.map((t) => t.exercise.id));
    for (final t in tasks) {
      final matches = words.where((w) => w.id == t.exercise.wordId);
      if (matches.isEmpty) fail('unknown_word');
      final w = matches.first;
      final e = t.exercise;
      if (t.type == 'choose_syllables' &&
          (w.syllables.length < 2 ||
              e.answer != w.syllables.join('-') ||
              e.options.any((o) => o.replaceAll('-', '') != w.text))) {
        fail('split_answer');
      }
      if (t.type == 'choose_ending' &&
          (w.ending == null || w.context == null || e.answer != w.ending)) {
        fail('ending_answer');
      }
      if (t.type == 'choose_parts') {
        final expected = [
          w.parts.firstOrNull,
          if (w.linkingElement.isNotEmpty) w.linkingElement,
          w.parts.lastOrNull,
        ].whereType<String>().join(' + ');
        if (w.parts.length != 2 || e.answer != expected) fail('parts_answer');
      }
      if (t.type == 'choose_line_break') {
        if (!w.lineBreaks.contains(e.answer) ||
            e.options.any((o) => o.replaceAll('-', '') != w.text) ||
            e.options.where(w.lineBreaks.contains).length != 1) {
          fail('line_answer');
        }
        if (w.parts.isNotEmpty &&
            w.linkingElement.isNotEmpty &&
            e.answer != '${w.parts[0]}${w.linkingElement}-${w.parts[1]}') {
          fail('linking_break');
        }
      }
      if (t.type == 'build_word' || t.type == 'build_compound') {
        final pieces = t.type == 'build_word' ? w.syllables : w.parts;
        if (t.type == 'build_compound' && w.linkingElement.isNotEmpty) {
          fail('build_link_not_supported');
        }
        // Two-tile tasks in this first dataset; both orders must be checkable.
        if (t.tiles.length != 2 ||
            e.answer != w.text ||
            t.tiles.toSet().length != 2 ||
            !e.options.contains(t.tiles.join()) ||
            !e.options.contains(t.tiles.reversed.join()) ||
            (t.tiles.toList()..sort()).join('|') !=
                (pieces.toList()..sort()).join('|')) {
          fail('build_answer');
        }
      }
    }
    final assigned = <String>[];
    for (final l in lessons) {
      ids(l.exerciseIds);
      for (final id in l.exerciseIds) {
        if (!tasks.any((t) => t.exercise.id == id)) fail('unknown_exercise');
        assigned.add(id);
      }
    }
    if (assigned.toSet().length != assigned.length ||
        assigned.length != tasks.length) {
      fail('exercise_assignment');
    }
    return SyllableContent(lessons, words, tasks);
  }
}

class SyllableRepository {
  Future<SyllableContent> load({AssetBundle? bundle}) async =>
      SyllableValidator.parse(
        jsonDecode(
          await (bundle ?? rootBundle).loadString(
            'assets/data/syllables_endings_v2.json',
          ),
        ) as Map<String, dynamic>,
      );
}

class WordStructureRepository {
  Future<SyllableContent> load({AssetBundle? bundle}) async =>
      SyllableValidator.parse(
        jsonDecode(
          await (bundle ?? rootBundle).loadString(
            'assets/data/word_structure_v3.json',
          ),
        ) as Map<String, dynamic>,
        moduleId: 'ordstruktur',
      );
}
