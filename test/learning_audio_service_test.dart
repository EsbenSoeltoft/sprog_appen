import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/features/audio/learning_audio_service.dart';
import 'package:sprog_appen/features/lydtrappen/data/lesson_repository.dart';

import 'support/fakes.dart';

WordEntry assetWord() {
  final d = fixture();
  d['words'][0]['audio']['assetPath'] = 'assets/audio/words/hest.mp3';
  return ContentValidator.parse(d).words.first;
}

void main() {
  test(
    'approved asset precedes TTS; unapproved asset uses whole-word TTS',
    () async {
      final b = FakeAudioBackend();
      final w = assetWord();
      final a = LearningAudioService(b, {w.assetPath!});
      expect((await a.playWord(w)).source, 'asset');
      expect(b.calls.contains('tts:hest'), false);
      await a.close();
      final b2 = FakeAudioBackend();
      final a2 = LearningAudioService(b2, {});
      expect((await a2.playWord(w)).source, 'tts');
      expect(b2.calls.contains('tts:hest'), true);
      expect(b2.calls.any((c) => c.startsWith('load:')), false);
      await a2.close();
    },
  );
  test(
    'missing asset falls back to Danish; missing Danish never speaks English',
    () async {
      final b = FakeAudioBackend()..assetFails = true;
      final w = assetWord();
      final a = LearningAudioService(b, {w.assetPath!});
      expect((await a.playWord(w)).source, 'tts');
      b.danish = false;
      await a.diagnostics();
      b.calls.clear();
      expect((await a.playWord(w)).source, 'none');
      expect(b.calls.any((c) => c.startsWith('tts:')), false);
      expect(a.message, contains('Dansk tale'));
      await a.close();
    },
  );
  test('new request cancels stale load before it starts playback', () async {
    final b = FakeAudioBackend()..loadGate = Completer<void>();
    final w = assetWord();
    final a = LearningAudioService(b, {w.assetPath!});
    final first = a.playWord(w);
    await Future<void>.delayed(Duration.zero);
    final second = a.playWord(contentFixture().words[1]);
    b.loadGate!.complete();
    expect((await first).source, 'cancelled');
    expect((await second).source, 'tts');
    expect(b.calls.contains('asset'), false);
    expect(b.calls.where((c) => c.startsWith('tts:')).toList(), ['tts:kvinde']);
    await a.close();
  });
  test('playback errors are contained and stop/dispose are safe', () async {
    final b = FakeAudioBackend()..speakFails = true;
    final a = LearningAudioService(b, {});
    expect((await a.playWord(contentFixture().words.first)).error, isNotNull);
    expect(a.busy, false);
    await a.stop();
    await a.close();
    expect(b.calls.last, 'dispose');
  });
  test(
    'a new word stops active speech before starting the next word',
    () async {
      final b = FakeAudioBackend()..holdSpeech = true;
      final a = LearningAudioService(b, {});
      // The fake stop completes speech; give a separate gate to the active utterance.
      final first = a.playWord(contentFixture().words.first);
      await Future<void>.delayed(Duration.zero);
      final second = a.playWord(contentFixture().words[1]);
      await Future<void>.delayed(Duration.zero);
      await a.stop();
      await Future.wait([first, second]);
      final firstSpeech = b.calls.indexOf('tts:hest');
      final secondSpeech = b.calls.indexOf('tts:kvinde');
      expect(b.calls.sublist(firstSpeech + 1, secondSpeech), contains('stop'));
      await a.close();
    },
  );
}
