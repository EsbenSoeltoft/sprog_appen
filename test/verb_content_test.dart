import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/features/udsagnsord/verb_repository.dart';
import 'package:sprog_appen/features/lydtrappen/logic/exercise_controller.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

import 'support/fakes.dart';

Map<String, dynamic> verbFixture() =>
    jsonDecode(File('assets/data/verbs_v4.json').readAsStringSync())
        as Map<String, dynamic>;
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'four complete draft paradigms and ten tasks load from real bundle',
    () async {
      final d = await VerbRepository().load();
      expect(d.verbs.length, 4);
      expect(d.practice.tasks.length, 10);
      expect(d.practice.tasks.map((t) => t.type).toSet(), {
        'choose_form',
        'fill_form',
        'match_tense',
      });
      expect(
        d.verbs.every((v) => v.status == 'draft' && v.forms.length == 4),
        true,
      );
      expect(
        d.verbs.firstWhere((v) => v.id == 'v4-verb-gaa').forms['perfect'],
        'er gået',
      );
      expect(
        d.verbs.firstWhere((v) => v.id == 'v4-verb-vaere').forms['perfect'],
        'har været',
      );
      expect(
        d.practice.words.every(
          (w) => w.ttsText == w.text && !w.text.contains('_'),
        ),
        true,
      );
    },
  );
  void invalid(
    String name,
    void Function(Map<String, dynamic>) change,
    String code,
  ) {
    test(name, () {
      final d = verbFixture();
      change(d);
      expect(
        () => VerbValidator.parse(d),
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
    'unknown verb',
    (d) => d['exercises'][0]['verbId'] = 'missing',
    'unknown_verb',
  );
  invalid(
    'unknown form',
    (d) => d['exercises'][0]['form'] = 'future',
    'unknown_form',
  );
  invalid(
    'answer must match paradigm',
    (d) => d['exercises'][0]['answer'] = 'legede',
    'answer',
  );
  invalid('missing auxiliary', (d) {
    d['verbs'][0]['forms']['perfect'] = 'leget';
  }, 'auxiliary');
  invalid(
    'sentence must contain canonical form',
    (d) => d['verbs'][0]['sentences']['past'] = 'Jeg leger.',
    'sentence',
  );
  invalid(
    'no missing form',
    (d) => d['verbs'][0]['forms'].remove('past'),
    'paradigm',
  );
  invalid(
    'unique exercise IDs',
    (d) => d['exercises'][1]['id'] = d['exercises'][0]['id'],
    'duplicate_or_invalid_id',
  );
  invalid(
    'match choices are grammatical labels',
    (d) => d['exercises'][6]['options'] = ['navneform', 'i morgen'],
    'tense_options',
  );
  invalid(
    'free-text exercise must not become multiple-choice',
    (d) => d['exercises'][3]['options'] = ['legede'],
    'options',
  );
  test(
    'free text tolerates case/spacing, rejects wrong form and keeps history',
    () async {
      final state = fakeState();
      final p = ProgressRepository(MemoryStore());
      final c = ExerciseController(
        state.verbs!.practice.forLesson('v4-skriv-form'),
        p,
      );
      await c.submit(normaliseVerbAnswer('   '), allowFreeText: true);
      expect(c.correct, isNull);
      expect(p.stats, isEmpty);
      await c.submit('leger', allowFreeText: true);
      expect(c.correct, false);
      c.retry();
      await c.submit(normaliseVerbAnswer('  LEGEDE  '), allowFreeText: true);
      expect(c.correct, true);
      c.next();
      await c.submit(normaliseVerbAnswer('GIK'), allowFreeText: true);
      c.next();
      await c.submit(normaliseVerbAnswer(' har   spist '), allowFreeText: true);
      expect(c.correct, true);
      expect(p.stats['v4-fill-lege']!.totalAttempts, 2);
      expect(p.stats['v4-fill-lege']!.firstAttemptCorrect, false);
      c.dispose();
      p.dispose();
      await state.audio.close();
      state.dispose();
    },
  );
  test(
    'progress restores all four modules without storing typed answers',
    () async {
      final state = fakeState();
      final store = MemoryStore();
      final p = ProgressRepository(store);
      for (final id in [
        'ex-hest',
        'v2-ending-biler',
        'v3-line-skole',
        'v4-fill-gaa',
      ]) {
        await p.record(id, true);
      }
      final restored = ProgressRepository(store);
      await restored.load({
        ...state.content.exercises.map((e) => e.id),
        ...state.syllables!.exerciseIds,
        ...state.wordStructure!.exerciseIds,
        ...state.verbs!.practice.exerciseIds,
      });
      expect(restored.stats.length, 4);
      expect(store.value, isNot(contains('answer')));
      p.dispose();
      restored.dispose();
      await state.audio.close();
      state.dispose();
    },
  );
}
