import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sprog_appen/features/udsagnsord/verb_repository.dart';

import 'package:sprog_appen/features/stavelser_endelser/data/syllable_repository.dart';

import 'package:sprog_appen/app/app_state.dart';
import 'package:sprog_appen/features/audio/learning_audio_service.dart';
import 'package:sprog_appen/features/lydtrappen/data/lesson_repository.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

Map<String, dynamic> fixture() =>
    jsonDecode(File('assets/data/vowel_ladders_v1.json').readAsStringSync())
        as Map<String, dynamic>;
LessonContent contentFixture() => ContentValidator.parse(fixture());

class MemoryStore implements ProgressStore {
  String? value;
  bool fail = false;
  @override
  Future<String?> read() async {
    if (fail) throw StateError('storage unavailable');
    return value;
  }

  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('storage unavailable');
    this.value = value;
  }
}

class FakeAudioBackend implements AudioBackend {
  bool danish = true, assetFails = false, speakFails = false;
  bool holdSpeech = false;
  final List<String> calls = [];
  Completer<void>? loadGate;
  Completer<void>? speech;
  @override
  Future<AudioDiagnostics> diagnostics() async {
    calls.add('diagnostics');
    return AudioDiagnostics(
      danish,
      danish ? 'da-DK fake' : 'missing_da_DK_voice',
    );
  }

  @override
  Future<void> loadAsset(String path) async {
    calls.add('load:$path');
    await loadGate?.future;
    if (assetFails) throw StateError('missing_asset');
  }

  @override
  Future<void> playAsset() async {
    calls.add('asset');
  }

  @override
  Future<void> speak(String word) async {
    calls.add('tts:$word');
    if (speakFails) throw StateError('tts_failed');
    if (holdSpeech) speech = Completer<void>();
    await speech?.future;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    if (speech != null && !speech!.isCompleted) speech!.complete();
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

AppState fakeState() {
  final content = contentFixture();
  return AppState(
    content,
    ProgressRepository(MemoryStore()),
    LearningAudioService(FakeAudioBackend(), {}),
    verbs: VerbValidator.parse(
      jsonDecode(File('assets/data/verbs_v4.json').readAsStringSync())
          as Map<String, dynamic>,
    ),
    wordStructure: SyllableValidator.parse(
      jsonDecode(File('assets/data/word_structure_v3.json').readAsStringSync())
          as Map<String, dynamic>,
      moduleId: 'ordstruktur',
    ),
    syllables: SyllableValidator.parse(
      jsonDecode(
        File('assets/data/syllables_endings_v2.json').readAsStringSync(),
      ) as Map<String, dynamic>,
    ),
  );
}
