import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../audio/audio_word_button.dart';
import '../stavelser_endelser/data/syllable_repository.dart';
import 'verb_repository.dart';

class VerbReference extends StatelessWidget {
  const VerbReference(this.state, {super.key});
  final AppState state;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Navneform er grundformen, fx at lege. Den er ikke en tid. Nutid og datid viser forskellige tidsformer. Førnutid dannes her med har eller er og en form som leget eller gået. Hjælpeverbet vælges i sammenhængen.',
      ),
      for (final verb in state.verbs!.verbs)
        Card.outlined(
          child: ExpansionTile(
            title: Text(verb.forms['infinitive']!),
            subtitle: Text(verb.explanation),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              for (final entry in verbFormLabels.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.value}: ${verb.forms[entry.key]}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(verb.sentences[entry.key]!),
                      AudioWordButton(
                        state.audio,
                        SyllableWord(
                          id: '${verb.id}-${entry.key}',
                          text: verb.sentences[entry.key]!,
                          syllables: const [],
                          explanation: verb.explanation,
                          contentStatus: verb.status,
                          ttsText: verb.sentences[entry.key]!,
                          locale: 'da-DK',
                        ),
                        label: 'Hør sætningen',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    ],
  );
}
