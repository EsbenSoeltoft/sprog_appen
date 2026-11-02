import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import 'spoken_word.dart';

class AudioDiagnostics {
  const AudioDiagnostics(this.danishAvailable, this.detail);
  final bool danishAvailable;
  final String detail;
}

class AudioPlaybackResult {
  const AudioPlaybackResult(this.source, {this.error});
  final String source;
  final String? error;
}

abstract interface class AudioBackend {
  Future<AudioDiagnostics> diagnostics();
  Future<void> loadAsset(String path);
  Future<void> playAsset();
  Future<void> speak(String word);
  Future<void> stop();
  Future<void> dispose();
}

class DeviceAudioBackend implements AudioBackend {
  final _player = AudioPlayer();
  final _tts = FlutterTts();
  @override
  Future<AudioDiagnostics> diagnostics() async {
    try {
      final languages = await _tts.getLanguages;
      final voices = await _tts.getVoices;
      final danish = voices is List
          ? voices
                .whereType<Map>()
                .where(
                  (v) =>
                      (v['locale'] as String? ?? '')
                          .replaceAll('_', '-')
                          .toLowerCase() ==
                      'da-dk',
                )
                .toList()
          : <Map>[];
      if (languages is! List ||
          !languages.any(
            (l) => l.toString().replaceAll('_', '-').toLowerCase() == 'da-dk',
          ) ||
          danish.isEmpty) {
        return const AudioDiagnostics(false, 'missing_da_DK_voice');
      }
      final voice = danish.first;
      if (await _tts.setLanguage('da-DK') != 1) {
        return const AudioDiagnostics(false, 'set_language_failed');
      }
      if (await _tts.setVoice({
            'name': voice['name'].toString(),
            'locale': voice['locale'].toString(),
          }) !=
          1) {
        return const AudioDiagnostics(false, 'set_voice_failed');
      }
      await _tts.setSpeechRate(0.45);
      await _tts.awaitSpeakCompletion(true);
      return AudioDiagnostics(
        true,
        'da-DK · ${voice['name']} · syntetisk tale; netværk kan være nødvendigt',
      );
    } catch (e) {
      return AudioDiagnostics(false, 'tts_error: $e');
    }
  }

  @override
  Future<void> loadAsset(String path) async {
    await _player.setAsset(path);
    await _player.seek(Duration.zero);
  }

  @override
  Future<void> playAsset() async {
    final failure = Completer<Object>();
    final subscription = _player.errorStream.listen((error) {
      if (!failure.isCompleted) failure.complete(error);
    });
    try {
      await Future.any<void>([
        _player.play(),
        failure.future.then<void>((error) => throw error),
      ]);
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<void> speak(String word) async {
    if (await _tts.speak(word) != 1) throw StateError('speak_failed');
  }

  @override
  Future<void> stop() async {
    // Try both even if one platform backend is unavailable.
    await Future.wait([_player.stop(), _tts.stop().then<void>((_) {})]);
  }

  @override
  Future<void> dispose() async {
    try {
      await _tts.stop();
    } finally {
      await _player.dispose();
    }
  }
}

class LearningAudioService extends ChangeNotifier {
  LearningAudioService(this.backend, this.approvedAssets);
  final AudioBackend backend;
  final Set<String> approvedAssets;
  AudioDiagnostics? status;
  String? message;
  bool busy = false;
  int _request = 0;
  bool _disposed = false;
  Future<void> _queue = Future.value();
  Future<void> _serial(Future<void> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.catchError((Object _) {});
    return next;
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<AudioDiagnostics> diagnostics() async {
    await _serial(() async {
      status = await backend.diagnostics();
    });
    _changed();
    return status!;
  }

  Future<AudioPlaybackResult> playWord(SpokenWord word) async {
    if (_disposed) return const AudioPlaybackResult('none', error: 'disposed');
    final request = ++_request;
    busy = true;
    message = null;
    _changed();
    Future<void>? playback;
    Object? playbackError;
    var source = 'none';
    String? detail;
    try {
      await _serial(() async {
        await backend.stop();
        if (request != _request || _disposed) return;
        final path = word.assetPath;
        if (path != null && approvedAssets.contains(path)) {
          try {
            await backend.loadAsset(path);
            source = 'asset';
          } catch (e) {
            detail = 'asset_error: $e';
          }
        }
        if (request != _request || _disposed) return;
        if (source != 'asset') {
          status ??= await backend.diagnostics();
          if (request != _request || _disposed) return;
          if (!status!.danishAvailable ||
              word.locale != 'da-DK' ||
              word.ttsText != word.text) {
            message = 'Dansk tale er ikke tilgængelig på denne enhed. Du kan stadig læse og øve.';
            detail = '${detail ?? ''} ${status!.detail}';
            return;
          }
          source = 'tts';
        }
        playback = source == 'asset'
            ? backend.playAsset()
            : backend.speak(word.ttsText);
        // Attach an error handler immediately, even before the serial setup returns.
        playback = playback!.catchError((Object e) {
          playbackError = e;
        });
      });
      if (playback != null) await playback;
      if (playbackError != null) throw StateError(playbackError.toString());
      return AudioPlaybackResult(
        request == _request ? source : 'cancelled',
        error: detail,
      );
    } catch (e) {
      if (request != _request) return const AudioPlaybackResult('cancelled');
      if (request == _request) {
        message =
            'Lyden kunne ikke afspilles. Prøv igen, eller fortsæt med teksten.';
      }
      return AudioPlaybackResult('none', error: e.toString());
    } finally {
      if (request == _request) {
        busy = false;
        _changed();
      }
    }
  }

  Future<void> stop() async {
    ++_request;
    busy = false;
    try {
      await _serial(backend.stop);
    } catch (e) {
      if (kDebugMode) debugPrint('Audio stop failed: $e');
    }
    _changed();
  }

  Future<void> close() async {
    if (_disposed) return;
    await stop();
    _disposed = true;
    await _serial(backend.dispose);
    super.dispose();
  }
}
