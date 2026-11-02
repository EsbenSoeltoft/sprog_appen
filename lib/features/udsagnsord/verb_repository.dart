import 'dart:convert';

import 'package:flutter/services.dart';

import '../stavelser_endelser/data/syllable_repository.dart';
import '../lydtrappen/data/lesson_repository.dart';

const verbFormLabels = {
  'infinitive': 'navneform',
  'present': 'nutid',
  'past': 'datid',
  'perfect': 'førnutid',
};
String normaliseVerbAnswer(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

class VerbParadigm {
  const VerbParadigm(
    this.id,
    this.forms,
    this.sentences,
    this.explanation,
    this.status,
  );
  final String id, explanation, status;
  final Map<String, String> forms, sentences;
}

class VerbContent {
  const VerbContent(this.verbs, this.practice);
  final List<VerbParadigm> verbs;
  final SyllableContent practice;
}

class VerbValidator {
  static VerbContent parse(Map<String, dynamic> data) {
    Never fail(String code) => throw FormatException('v4:$code');
    String text(Map<String, dynamic> m, String key) {
      final v = m[key];
      if (v is! String || v.trim().isEmpty) fail('missing:$key');
      return v;
    }

    List<Map<String, dynamic>> rows(String key) {
      final v = data[key];
      if (v is! List || v.isEmpty || v.any((e) => e is! Map<String, dynamic>)) {
        fail('invalid:$key');
      }
      return v.cast<Map<String, dynamic>>();
    }

    List<String> strings(Object? v) {
      if (v is! List || v.any((e) => e is! String || e.isEmpty)) {
        fail('invalid_list');
      }
      return v.cast<String>();
    }

    if (data['schemaVersion'] != 1 || data['moduleId'] != 'udsagnsord') {
      fail('schema');
    }
    final verbs = rows('verbs').map((m) {
      final forms = m['forms'], sentences = m['sentences'];
      if (forms is! Map<String, dynamic> ||
          sentences is! Map<String, dynamic> ||
          forms.length != 4 ||
          sentences.length != 4) {
        fail('paradigm');
      }
      for (final key in verbFormLabels.keys) {
        final form = text(forms, key), sentence = text(sentences, key);
        if (!sentence.contains(form) || sentence.contains('_')) {
          fail('sentence');
        }
        if (key == 'infinitive' && !form.startsWith('at ')) fail('infinitive');
        if (key == 'perfect' &&
            (!form.startsWith('har ') && !form.startsWith('er '))) {
          fail('auxiliary');
        }
      }
      final status = text(m, 'contentStatus');
      if (!['draft', 'approved'].contains(status)) fail('status');
      return VerbParadigm(
        text(m, 'id'),
        forms.cast<String, String>(),
        sentences.cast<String, String>(),
        text(m, 'explanation'),
        status,
      );
    }).toList();
    final words = <SyllableWord>[];
    final tasks = rows('exercises').map((m) {
      final id = text(m, 'id'),
          verbId = text(m, 'verbId'),
          form = text(m, 'form'),
          type = text(m, 'type');
      final matches = verbs.where((v) => v.id == verbId);
      if (matches.isEmpty) fail('unknown_verb');
      final verb = matches.first;
      if (!verbFormLabels.containsKey(form)) fail('unknown_form');
      if (!['choose_form', 'fill_form', 'match_tense'].contains(type)) {
        fail('type');
      }
      final expected = type == 'match_tense'
          ? verbFormLabels[form]!
          : verb.forms[form]!;
      final answer = text(m, 'answer');
      final options = strings(m['options']);
      if (answer != expected || options.toSet().length != options.length) {
        fail('answer');
      }
      if (type == 'fill_form'
          ? options.isNotEmpty
          : options.length < 2 || !options.contains(answer)) {
        fail('options');
      }
      if (type == 'match_tense' &&
          options.any((o) => !verbFormLabels.values.contains(o))) {
        fail('tense_options');
      }
      if (type == 'choose_form' &&
          options.any((o) => !verb.forms.values.contains(o))) {
        fail('form_options');
      }
      final sentence = verb.sentences[form]!;
      final wordId = '$id-sentence';
      final explanation =
          '${verb.forms[form]} er ${verbFormLabels[form]}. ${verb.explanation}';
      words.add(
        SyllableWord(
          id: wordId,
          text: sentence,
          syllables: const [],
          explanation: explanation,
          contentStatus: verb.status,
          ttsText: sentence,
          locale: 'da-DK',
        ),
      );
      final gap = type == 'match_tense'
          ? ''
          : sentence.replaceFirst(verb.forms[form]!, '____');
      return SyllableTask(
        Exercise(id, wordId, gap, options, answer),
        type,
        text(m, 'prompt'),
        const [],
      );
    }).toList();
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
    void ids(Iterable<String> ids) {
      final list = ids.toList();
      if (list.isEmpty ||
          list.toSet().length != list.length ||
          list.any((id) => !RegExp(r'^v4-[a-z0-9-]+$').hasMatch(id))) {
        fail('duplicate_or_invalid_id');
      }
    }

    ids(verbs.map((v) => v.id));
    ids(tasks.map((t) => t.exercise.id));
    ids(lessons.map((l) => l.id));
    final assigned = <String>[];
    for (final lesson in lessons) {
      ids(lesson.exerciseIds);
      for (final id in lesson.exerciseIds) {
        if (!tasks.any((t) => t.exercise.id == id)) fail('unknown_exercise');
        assigned.add(id);
      }
    }
    if (assigned.toSet().length != assigned.length ||
        assigned.length != tasks.length) {
      fail('exercise_assignment');
    }
    return VerbContent(verbs, SyllableContent(lessons, words, tasks));
  }
}

class VerbRepository {
  Future<VerbContent> load({AssetBundle? bundle}) async => VerbValidator.parse(
    jsonDecode(
      await (bundle ?? rootBundle).loadString('assets/data/verbs_v4.json'),
    ) as Map<String, dynamic>,
  );
}
