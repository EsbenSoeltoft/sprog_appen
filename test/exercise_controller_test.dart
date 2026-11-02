import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/features/lydtrappen/logic/exercise_controller.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

import 'support/fakes.dart';

void main() {
  test('wrong, retry, correct, next and replay preserve history', () async {
    final data = contentFixture();
    final store = MemoryStore();
    final progress = ProgressRepository(store);
    final c = ExerciseController(data.forLadder('i-e-ae-a'), progress);
    final first = c.current;
    await c.submit(first.options.firstWhere((o) => o != first.answer));
    expect(c.correct, false);
    c.next();
    expect(c.index, 0);
    c.retry();
    await c.submit(first.answer);
    await c.submit(first.answer);
    expect(progress.stats[first.id]!.totalAttempts, 2);
    expect(progress.stats[first.id]!.firstAttemptCorrect, false);
    c.next();
    expect(c.index, 1);
    while (!c.finished) {
      await c.submit(c.current.answer);
      c.next();
    }
    c.restart();
    expect(c.index, 0);
    expect(progress.stats[first.id]!.completed, true);
    final restored = ProgressRepository(store);
    await restored.load(data.exercises.map((e) => e.id).toSet());
    expect(restored.stats[first.id]!.totalAttempts, 2);
    expect(restored.stats[first.id]!.completed, true);
    await restored.reset();
    final cleared = ProgressRepository(store);
    await cleared.load({first.id});
    expect(cleared.stats, isEmpty);
    c.dispose();
    progress.dispose();
    restored.dispose();
    cleared.dispose();
  });
  test('corrupt progress and failed storage remain usable', () async {
    final store = MemoryStore()..value = 'broken json';
    final p = ProgressRepository(store);
    await p.load({'ex-hest'});
    expect(p.stats, isEmpty);
    expect(p.warning, isNotNull);
    store.fail = true;
    await p.record('ex-hest', true);
    expect(p.stats['ex-hest']!.completed, true);
    expect(p.warning, isNotNull);
    p.dispose();
  });
  test('future dates are rejected and unknown IDs ignored', () async {
    final store = MemoryStore()
      ..value =
          '{"schemaVersion":1,"exerciseStats":{"ex-hest":{"totalAttempts":1,"firstAttemptCorrect":true,"lastCompletedAt":"2999-01-01T00:00:00Z"}}}';
    final p = ProgressRepository(store);
    await p.load({'ex-hest'});
    expect(p.stats, isEmpty);
    store.value = '{"schemaVersion":1,"exerciseStats":{"removed":{}}}';
    await p.load({'ex-hest'});
    expect(p.stats, isEmpty);
    p.dispose();
  });
}
