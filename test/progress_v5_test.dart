import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

import 'support/fakes.dart';

void main() {
  test('schema one migrates without losing attempts or completion', () async {
    final store = MemoryStore()
      ..value = jsonEncode({
        'schemaVersion': 1,
        'exerciseStats': {
          'ex-hest': {
            'totalAttempts': 2,
            'firstAttemptCorrect': false,
            'lastCompletedAt': '2026-01-01T00:00:00Z',
          },
        },
      });
    final p = ProgressRepository(store);
    await p.load({'ex-hest', 'ex-kvinde'});
    expect(p.stats['ex-hest']!.totalAttempts, 2);
    expect(p.stats['ex-hest']!.completed, true);
    await p.setLevel(PracticeLevel.independent);
    await p.setResume(
      const ResumePosition('/lydtrappe/vokaler', 'i-e-ae-a', 'ex-kvinde'),
    );
    final raw = jsonDecode(store.value!) as Map;
    expect(raw['schemaVersion'], 2);
    final r = ProgressRepository(store);
    await r.load({'ex-hest', 'ex-kvinde'});
    expect(r.level, PracticeLevel.independent);
    expect(r.resume!.exerciseId, 'ex-kvinde');
    expect(r.stats['ex-hest']!.completed, true);
    p.dispose();
    r.dispose();
  });
  test(
    'review stays after retry, clears on a successful later repeat',
    () async {
      final p = ProgressRepository(MemoryStore());
      await p.record('ex-hest', false);
      await p.record('ex-hest', true);
      expect(p.stats['ex-hest']!.reviewNeeded, true);
      await p.record('ex-hest', true);
      expect(p.stats['ex-hest']!.reviewNeeded, false);
      expect(p.stats['ex-hest']!.firstAttemptCorrect, false);
      p.dispose();
    },
  );
  test(
    'controller position, answer feedback, next and finish persist',
    () async {
      final state = fakeState();
      final session = state.practiceSession('/udsagnsord', 'v4-skriv-form');
      await session.visit();
      await session.submit('legede', allowFreeText: true);
      expect(state.progress.resume!.correct, true);
      session.next();
      await state.progress.flush();
      expect(state.progress.resume!.exerciseId, 'v4-fill-gaa');
      expect(state.progress.resume!.correct, isNull);
      await session.submit('gik', allowFreeText: true);
      session.next();
      await session.submit('har spist', allowFreeText: true);
      session.next();
      await state.progress.flush();
      expect(state.progress.resume, isNull);
      await state.audio.close();
      state.dispose();
    },
  );
  test('app state restores the saved question and feedback without adding attempts', () async {
    final first = fakeState();
    await first.progress.record('v4-fill-lege', true);
    await first.progress.record('v4-fill-gaa', false);
    await first.progress.setResume(
      const ResumePosition(
        '/udsagnsord',
        'v4-skriv-form',
        'v4-fill-gaa',
        correct: false,
      ),
    );
    final store = first.progress.store;
    final second = fakeState();
    await second.progress.load(second.targets.map((t) => t.exerciseId).toSet());
    // Use a fresh repository bound to the same persisted bytes, then copy into the injected fake store.
    (second.progress.store as MemoryStore).value = (store as MemoryStore).value;
    await second.progress.load(second.targets.map((t) => t.exerciseId).toSet());
    final s = second.practiceSession('/udsagnsord', 'v4-skriv-form');
    expect(s.current.id, 'v4-fill-gaa');
    expect(s.correct, false);
    expect(second.progress.stats.length, 2);
    await first.audio.close();
    first.dispose();
    await second.audio.close();
    second.dispose();
  });
  test(
    'recommendation prioritises review then unfinished then oldest completed',
    () async {
      final state = fakeState();
      expect(state.recommendation!.exerciseId, 'ex-hest');
      await state.progress.record('v4-fill-gaa', false);
      await state.progress.record('v4-fill-gaa', true);
      expect(state.recommendation!.exerciseId, 'v4-fill-gaa');
      await state.progress.record('v4-fill-gaa', true);
      expect(state.recommendation!.exerciseId, 'ex-hest');
      for (final t in state.targets) {
        await state.progress.record(t.exerciseId, true);
      }
      expect(state.completedLessons, 13);
      expect(state.recommendation, isNotNull);
      await state.audio.close();
      state.dispose();
    },
  );
  test(
    'other local profiles are preserved when active profile is reset',
    () async {
      final store = MemoryStore()
        ..value = jsonEncode({
          'schemaVersion': 2,
          'activeProfileId': 'local-default',
          'profiles': {
            'local-default': {'exerciseStats': {}, 'level': 'independent'},
            'local-other': {'exerciseStats': {}, 'level': 'supported'},
          },
        });
      final p = ProgressRepository(store);
      await p.load({'ex-hest'});
      await p.record('ex-hest', true);
      await p.reset();
      final raw = jsonDecode(store.value!) as Map;
      expect(raw['profiles']['local-other']['level'], 'supported');
      expect(p.level, PracticeLevel.supported);
      expect(p.stats, isEmpty);
      expect(p.resume, isNull);
      p.dispose();
    },
  );
  test(
    'invalid position and unknown level fall back without losing valid history',
    () async {
      final store = MemoryStore()
        ..value = jsonEncode({
          'schemaVersion': 2,
          'activeProfileId': 'local-default',
          'profiles': {
            'local-default': {
              'exerciseStats': {},
              'level': 'nonsense',
              'resume': {
                'modulePath': 'https://example.com',
                'lessonId': 'x',
                'exerciseId': 'ex-hest',
              },
            },
          },
        });
      final p = ProgressRepository(store);
      await p.load({'ex-hest'});
      expect(p.level, PracticeLevel.supported);
      expect(p.resume, isNull);
      p.dispose();
    },
  );
  test('unknown target is not offered by continue; failed writes keep session usable', () async {
    final state = fakeState();
    await state.progress.setResume(
      const ResumePosition('/udsagnsord', 'missing', 'v4-fill-gaa'),
    );
    expect(state.resumeTarget, isNull);
    (state.progress.store as MemoryStore).fail = true;
    await state.progress.setLevel(PracticeLevel.independent);
    expect(state.progress.warning, isNotNull);
    expect(state.progress.level, PracticeLevel.independent);
    await state.audio.close();
    state.dispose();
  });
}
