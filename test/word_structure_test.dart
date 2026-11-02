import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/features/stavelser_endelser/data/syllable_repository.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

import 'support/fakes.dart';

Map<String, dynamic> fixtureV3() =>
    jsonDecode(File('assets/data/word_structure_v3.json').readAsStringSync())
        as Map<String, dynamic>;
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'four distinct learning goals, eight draft exercises and real asset load',
    () async {
      final d = await WordStructureRepository().load();
      expect(d.lessons.length, 4);
      expect(d.tasks.length, 8);
      expect(
        d.words.every(
          (w) =>
              w.contentStatus == 'draft' &&
              w.ttsText == w.text &&
              w.assetPath == null,
        ),
        true,
      );
      expect(d.tasks.map((t) => t.type).toSet(), {
        'build_compound',
        'choose_parts',
        'choose_syllables',
        'choose_line_break',
      });
      final sol = d.word('v3-word-solbriller');
      expect(sol.parts, ['sol', 'briller']);
      expect(sol.syllables, ['sol', 'bril', 'ler']);
      for (final t in d.tasks) {
        expect(t.exercise.accepts(t.exercise.answer), true);
        for (final wrong in t.exercise.options.where(
          (o) => o != t.exercise.answer,
        )) {
          expect(t.exercise.accepts(wrong), false);
        }
      }
    },
  );
  void invalid(
    String name,
    void Function(Map<String, dynamic>) mutate,
    String code,
  ) {
    test(name, () {
      final d = fixtureV3();
      mutate(d);
      expect(
        () => SyllableValidator.parse(d, moduleId: 'ordstruktur'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'code',
            contains(code),
          ),
        ),
      );
    });
  }

  invalid(
    'compound parts reconstruct written word',
    (d) => d['words'][0]['parts'] = ['sol', 'bril'],
    'compound_parts',
  );
  invalid(
    'linking element is explicit',
    (d) => d['words'][2]['linkingElement'] = 'e',
    'compound_parts',
  );
  invalid('no splitting before linking s', (d) {
    d['words'][2]['lineBreaks'] = ['bibliotek-sbog'];
    d['exercises'][7]['answer'] = 'bibliotek-sbog';
  }, 'linking_break');
  invalid(
    'both printed lines need a vowel',
    (d) => d['words'][4]['lineBreaks'] = ['sk-ole'],
    'line_break',
  );
  invalid(
    'syllables are not interchangeable with meaningful parts',
    (d) => d['exercises'][2]['answer'] = 'sol + bril + ler',
    'parts_answer',
  );
  invalid(
    'unknown lesson exercise',
    (d) => d['lessons'][0]['exerciseIds'][0] = 'v3-missing',
    'unknown_exercise',
  );
  invalid(
    'duplicate tasks',
    (d) => d['exercises'][1]['id'] = d['exercises'][0]['id'],
    'duplicate_or_invalid_id',
  );
  invalid(
    'no missing word reference',
    (d) => d['exercises'][0]['wordId'] = 'v3-missing',
    'unknown_word',
  );
  invalid(
    'a line-break answer must be curated',
    (d) => d['exercises'][6]['answer'] = 'sk-ole',
    'line_answer',
  );
  test('three modules keep independent stored history', () async {
    final state = fakeState();
    final store = MemoryStore();
    final p = ProgressRepository(store);
    await p.record('ex-hest', true);
    await p.record('v2-ending-biler', true);
    await p.record('v3-line-biblioteksbog', false);
    await p.record('v3-line-biblioteksbog', true);
    final restored = ProgressRepository(store);
    await restored.load({
      ...state.content.exercises.map((e) => e.id),
      ...state.syllables!.exerciseIds,
      ...state.wordStructure!.exerciseIds,
    });
    expect(restored.stats.length, 3);
    expect(restored.stats['v3-line-biblioteksbog']!.firstAttemptCorrect, false);
    expect(restored.stats['v3-line-biblioteksbog']!.totalAttempts, 2);
    p.dispose();
    restored.dispose();
    await state.audio.close();
    state.dispose();
  });
}
