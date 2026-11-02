import 'package:flutter/material.dart';

import 'learning_audio_service.dart';
import 'spoken_word.dart';

class AudioWordButton extends StatefulWidget {
  const AudioWordButton(
    this.audio,
    this.word, {
    super.key,
    this.label = 'Hør ordet',
  });
  final LearningAudioService audio;
  final SpokenWord word;
  final String label;
  @override
  State<AudioWordButton> createState() => _AudioWordButtonState();
}

class _AudioWordButtonState extends State<AudioWordButton> {
  String? _message;
  bool _playing = false;
  int _request = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.audio,
    builder: (context, _) {
      final unavailable =
          widget.audio.status?.danishAvailable == false &&
          !widget.audio.approvedAssets.contains(widget.word.assetPath);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _playing || unavailable
                    ? null
                    : () async {
                        final request = ++_request;
                        setState(() {
                          _playing = true;
                          _message = null;
                        });
                        final result = await widget.audio.playWord(widget.word);
                        if (mounted && request == _request) {
                          setState(() {
                            _playing = false;
                            _message =
                                widget.audio.message ??
                                (result.source == 'tts'
                                    ? 'Syntetisk dansk tale'
                                    : null);
                          });
                        }
                      },
                icon: const Icon(Icons.volume_up_outlined),
                label: Text(_playing ? 'Afspiller …' : widget.label),
              ),
              if (_playing)
                TextButton(
                  onPressed: () async {
                    ++_request;
                    await widget.audio.stop();
                    if (mounted) setState(() => _playing = false);
                  },
                  child: const Text('Stop lyd'),
                ),
            ],
          ),
          if (unavailable)
            const Text(
              'Dansk tale er ikke tilgængelig på denne enhed. Du kan stadig bruge læsehjælpen.',
            ),
          if (unavailable)
            TextButton(
              onPressed: () async {
                await widget.audio.diagnostics();
              },
              child: const Text('Kontrollér lyd igen'),
            ),
          if (_message != null)
            Semantics(liveRegion: true, child: Text(_message!)),
        ],
      );
    },
  );
}
