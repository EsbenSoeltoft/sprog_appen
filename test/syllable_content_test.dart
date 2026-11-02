import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/features/stavelser_endelser/data/syllable_repository.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';
import 'package:sprog_appen/features/lydtrappen/logic/exercise_controller.dart';

import 'support/fakes.dart';

Map<String, dynamic> v2Fixture() =>
    jsonDecode(File('assets/data/syllables_endings_v2.json').readAsStringSync())
        as Map<String, dynamic>;
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'real bundle: six tasks across three forms, all draft and whole-word TTS',
    () async {
      final data = await SyllableRepository().load();
      expect(data.lessons.length, 3);
      expect(data.tasks.length, 6);
      expect(data.tasks.map((t) => t.type).toSet().length, 3);
      expect(
        data.words.every(
          (w) =>
              w.contentStatus == 'draft' &&
              w.ttsText == w.text &&
              w.assetPath == null,
        ),
        true,
      );
      for (final t in data.tasks) {
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
    String label,
    void Function(Map<String, dynamic>) mutate,
    String code,
  ) {
    test(label, () {
      final d = v2Fixture();
      mutate(d);
      expect(
        () => SyllableValidator.parse(d),
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
    'unknown word',
    (d) => d['exercises'][0]['wordId'] = 'missing',
    'unknown_word',
  );
  invalid(
    'unknown exercise',
    (d) => d['lessons'][0]['exerciseIds'][0] = 'v2-missing',
    'unknown_exercise',
  );
  invalid(
    'duplicate ID',
    (d) => d['words'][1]['id'] = d['words'][0]['id'],
    'duplicate_or_invalid_id',
  );
  invalid(
    'syllables must reconstruct word',
    (d) => d['words'][0]['syllables'] = ['ka', 'ga'],
    'syllables',
  );
  invalid(
    'ending must reconstruct plural',
    (d) => d['words'][2]['ending'] = 'e',
    'ending_context',
  );
  invalid(
    'context must contain stem and gap',
    (d) => d['words'][2]['context'] = 'Der er biler.',
    'ending_context',
  );
  invalid(
    'no TTS of separate syllables',
    (d) => d['words'][0]['audio']['ttsText'] = 'ka',
    'whole_word_audio',
  );
  invalid(
    'building tiles must match syllables',
    (d) => d['exercises'][2]['tiles'] = ['le', 'ska'],
    'build_answer',
  );
  invalid(
    'answer must match real split',
    (d) => d['exercises'][0]['answer'] = 'kag-e',
    'split_answer',
  );
  invalid(
    'every task assigned once',
    (d) => d['lessons'][2]['exerciseIds'] = ['v2-ending-biler'],
    'exercise_assignment',
  );
  test(
    'both module IDs survive persistence reload; retry and replay keep history',
    () async {
      final state = fakeState();
      final store = MemoryStore();
      final progress = ProgressRepository(store);
      await progress.record('ex-hest', true);
      final data = state.syllables!;
      for (final l in data.lessons) {
        final c = ExerciseController(data.forLesson(l.id), progress);
        while (!c.finished) {
          final e = c.current;
          await c.submit(e.options.firstWhere((o) => o != e.answer));
          expect(c.correct, false);
          c.retry();
          await c.submit(e.answer);
          c.next();
        }
        c.restart();
        expect(c.index, 0);
        c.dispose();
      }
      final restored = ProgressRepository(store);
      await restored.load({
        ...state.content.exercises.map((e) => e.id),
        ...data.exerciseIds,
      });
      expect(restored.stats.length, 7);
      expect(restored.stats['ex-hest']!.completed, true);
      for (final id in data.exerciseIds) {
        expect(restored.stats[id]!.totalAttempts, 2);
        expect(restored.stats[id]!.firstAttemptCorrect, false);
      }
      progress.dispose();
      restored.dispose();
      await state.audio.close();
      state.dispose();
    },
  );
}
