import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../audio/learning_audio_service.dart';
import '../audio/audio_word_button.dart';
import '../../shared/widgets/learning_page.dart';
import '../stavelser_endelser/syllable_screen.dart';
import 'data/lesson_repository.dart';
import 'logic/exercise_controller.dart';
import '../progress/progress_repository.dart';
import '../progress/learning_dashboard.dart';

class LydtrappenScreen extends StatelessWidget {
  const LydtrappenScreen({super.key});
  @override
  Widget build(BuildContext context) => LearningPage(
    title: 'Lydtrappen',
    children: [
      Text(
        'Lyt. Gentag. Tag dig god tid.',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const Text(
        'Øv forbindelsen mellem vokalernes lyd og skrift i udvalgte ord.',
      ),
      const Text(
        'Prototype: ord og udtale afventer godkendelse. Talen er syntetisk, når der ikke er en godkendt optagelse.',
      ),
      FilledButton(
        onPressed: () => Navigator.pushNamed(context, '/lydtrappe/vokaler'),
        child: const Text('Vokaltrappen'),
      ),
    ],
  );
}

class LadderSteps extends StatelessWidget {
  const LadderSteps(this.ladder, {super.key, required this.group});
  final VowelLadder ladder;
  final int group;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Vokalrække ${ladder.letters.join(', derefter ')}',
    child: ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < ladder.letters.length; i++)
            Padding(
              padding: EdgeInsets.only(left: i * 20.0, bottom: 4),
              child: Container(
                constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: [
                    const Color(0xFFD8EBE4),
                    const Color(0xFFFFE5BD),
                    const Color(0xFFE7E0F3),
                  ][group % 3],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ladder.letters[i],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class VowelOverviewScreen extends StatelessWidget {
  const VowelOverviewScreen(this.state, {super.key});
  final AppState state;
  @override
  Widget build(BuildContext context) => LearningPage(
    title: 'Vokaltrappen',
    children: [
      const Text(
        'Tre vokalrækker. Lyd og stavning er ikke altid ens. Trapperne viser mulige mønstre i udvalgte ord, ikke en regel for alle ord.',
      ),
      for (var i = 0; i < state.content.ladders.length; i++)
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.content.ladders[i].label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                LadderSteps(state.content.ladders[i], group: i),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/lydtrappe/vokaler/${state.content.ladders[i].id}',
                  ),
                  child: Text('Se ord: ${state.content.ladders[i].label}'),
                ),
              ],
            ),
          ),
        ),
      const Text(
        'Lydhenvisninger er tilnærmelser. Udtalen kan variere. Rækken u – o – å betyder ikke, at u normalt bliver til o.',
      ),
    ],
  );
}

class LadderDetailScreen extends StatelessWidget {
  const LadderDetailScreen(this.state, this.ladder, {super.key});
  final AppState state;
  final VowelLadder ladder;
  @override
  Widget build(BuildContext context) {
    final exercises = state.content.forLadder(ladder.id);
    return LearningPage(
      title: ladder.label,
      children: [
        LadderSteps(ladder, group: state.content.ladders.indexOf(ladder)),
        const Text(
          'Se på den skrevne vokal, og hør den i hele ordet. Eksemplerne er foreløbige.',
        ),
        for (final word in state.content.words.where(
          (w) => w.ladderId == ladder.id,
        ))
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: '${word.text}, skrevet vokal ${word.spellingVowel}',
                    child: ExcludeSemantics(child: _WrittenWord(word)),
                  ),
                  const SizedBox(height: 8),
                  Text(word.explanation),
                  AudioWordButton(state.audio, word),
                  TextButton(
                    onPressed: () => _open(
                      context,
                      exercises.indexWhere((e) => e.wordId == word.id),
                    ),
                    child: Text('Øv ${word.text}'),
                  ),
                ],
              ),
            ),
          ),
        if (exercises.isNotEmpty)
          FilledButton(
            onPressed: () => _open(context, null),
            child: const Text('Start øvelser'),
          ),
        if (exercises.isEmpty)
          const Text('Der er endnu ingen øvelser i denne trappe.'),
      ],
    );
  }

  void _open(BuildContext context, int? index) {
    final session = state.session(ladder.id);
    if (index != null && index >= 0) {
      session.index = index;
      session.correct = null;
      session.finished = false;
    }
    if (session.finished) session.restart();
    Navigator.pushNamed(context, '/lydtrappe/oevelse/${session.current.id}');
  }
}

class _WrittenWord extends StatelessWidget {
  const _WrittenWord(this.word);
  final WordEntry word;
  @override
  Widget build(BuildContext context) {
    final at = word.text.indexOf(word.spellingVowel);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: word.text.substring(0, at)),
          TextSpan(
            text: word.spellingVowel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: word.text.substring(at + 1)),
        ],
      ),
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}

class WordExerciseScreen extends StatefulWidget {
  const WordExerciseScreen(this.state, this.session, {super.key});
  final AppState state;
  final ExerciseController session;
  @override
  State<WordExerciseScreen> createState() => _WordExerciseScreenState();
}

class _WordExerciseScreenState extends State<WordExerciseScreen> {
  bool _showWord = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.session,
    builder: (context, _) {
      final session = widget.session;
      final exercise = session.current;
      final word = widget.state.content.word(exercise.wordId);
      return LearningPage(
        title: 'Ordøvelse ${session.index + 1} af ${session.exercises.length}',
        children: [
          const Text(
            'Hvilken vokal mangler i ordet? Lyt til ordet, eller brug læsehjælpen.',
          ),
          Semantics(
            label:
                'Ord med en manglende vokal: ${exercise.maskedText.replaceFirst('_', ' blank ')}',
            child: Text(
              exercise.maskedText,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          AudioWordButton(widget.state.audio, word, key: ValueKey(exercise.id)),
          if (widget.state.progress.level == PracticeLevel.supported)
            TextButton(
              onPressed: () => setState(() => _showWord = !_showWord),
              child: Text(
                _showWord ? 'Skjul læsehjælp' : 'Vis læsehjælp uden lyd',
              ),
            ),
          if (_showWord &&
              widget.state.progress.level == PracticeLevel.supported)
            Text('Find vokalen i: ${word.text}'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final option in exercise.options)
                FilledButton(
                  onPressed: session.correct != null
                      ? null
                      : () => session.submit(option),
                  child: Semantics(
                    label: 'Vælg vokalen $option',
                    child: Text(option),
                  ),
                ),
            ],
          ),
          if (session.correct != null)
            Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.correct!
                        ? 'Ja, det er rigtigt!'
                        : 'Godt forsøgt. Se forklaringen og prøv igen.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    word.text,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(word.explanation),
                ],
              ),
            ),
          if (session.correct == false)
            FilledButton(
              onPressed: () {
                session.retry();
                setState(() => _showWord = false);
              },
              child: const Text('Prøv igen'),
            ),
          if (session.correct == true)
            FilledButton(
              onPressed: () {
                unawaited(widget.state.audio.stop());
                session.next();
                setState(() => _showWord = false);
                if (session.finished) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/lydtrappe/resultat/${word.ladderId}',
                  );
                }
              },
              child: const Text('Næste'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tilbage til trappen'),
          ),
        ],
      );
    },
  );
}

class ResultScreen extends StatelessWidget {
  const ResultScreen(this.state, this.ladder, {super.key});
  final AppState state;
  final VowelLadder ladder;
  @override
  Widget build(BuildContext context) => LearningPage(
    title: 'Flot øvet!',
    children: [
      ProgressSummary(state, ladder),
      const Text(
        'Du kan gentage ordene, så ofte du vil. Der er intet tidspres.',
      ),
      FilledButton(
        onPressed: () {
          final session = state.session(ladder.id);
          session.restart();
          Navigator.pushReplacementNamed(
            context,
            '/lydtrappe/oevelse/${session.current.id}',
          );
        },
        child: const Text('Start igen'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Tilbage til trappen'),
      ),
    ],
  );
}

class ProgressSummary extends StatelessWidget {
  const ProgressSummary(this.state, this.ladder, {super.key});
  final AppState state;
  final VowelLadder ladder;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state.progress,
    builder: (context, _) {
      final exercises = state.content.forLadder(ladder.id);
      final completed = exercises
          .where((e) => state.progress.stats[e.id]?.completed ?? false)
          .toList();
      final first = completed
          .where((e) => state.progress.stats[e.id]!.firstAttemptCorrect)
          .length;
      return Text(
        '${ladder.label}\nGennemført: ${completed.length} / ${exercises.length}\nRigtige første forsøg: $first / ${completed.length}',
        style: Theme.of(context).textTheme.titleMedium,
      );
    },
  );
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen(this.state, {super.key});
  final AppState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state.progress,
    builder: (context, _) => LearningPage(
      title: 'Fremskridt',
      children: [
        LearningDashboard(state),
        const Text(
          'Dine fremskridt gemmes kun på denne enhed. Gentagelser sletter ikke tidligere gennemførsel.',
        ),
        if (state.progress.warning != null) Text(state.progress.warning!),
        for (final ladder in state.content.ladders)
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressSummary(state, ladder),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/lydtrappe/vokaler/${ladder.id}',
                    ),
                    child: const Text('Øv igen'),
                  ),
                ],
              ),
            ),
          ),
        if (state.syllables != null) ...[
          const Text('Stavelser og endelser'),
          for (final lesson in state.syllables!.lessons)
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title),
                    SyllableProgress(state, lesson),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/stavelser/${lesson.id}',
                      ),
                      child: const Text('Øv orddele'),
                    ),
                  ],
                ),
              ),
            ),
        ],
        if (state.wordStructure != null) ...[
          const Text('Sammensatte ord og orddeling'),
          for (final lesson in state.wordStructure!.lessons)
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title),
                    SyllableProgress(state, lesson, modulePath: '/ordstruktur'),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/ordstruktur/${lesson.id}',
                      ),
                      child: const Text('Øv ordstruktur'),
                    ),
                  ],
                ),
              ),
            ),
        ],
        if (state.verbs != null) ...[
          const Text('Udsagnsord'),
          for (final lesson in state.verbs!.practice.lessons)
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title),
                    SyllableProgress(state, lesson, modulePath: '/udsagnsord'),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/udsagnsord/${lesson.id}',
                      ),
                      child: const Text('Øv udsagnsord'),
                    ),
                  ],
                ),
              ),
            ),
        ],
        OutlinedButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Nulstil fremskridt?'),
                content: const Text(
                  'Dine gennemførsler, forsøg, seneste placering og valg af hjælp nulstilles på denne enhed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Behold'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Nulstil'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await state.progress.reset();
              for (final lesson in state.verbs?.practice.lessons ?? []) {
                state
                    .practiceSession('/udsagnsord', lesson.id)
                    .restart(remember: false);
              }
              for (final lesson in state.wordStructure?.lessons ?? []) {
                state
                    .practiceSession('/ordstruktur', lesson.id)
                    .restart(remember: false);
              }
              for (final lesson in state.syllables?.lessons ?? []) {
                state.syllableSession(lesson.id).restart(remember: false);
              }
              for (final l in state.content.ladders) {
                state.session(l.id).restart(remember: false);
              }
            }
          },
          child: const Text('Nulstil fremskridt'),
        ),
      ],
    ),
  );
}

class AudioTestScreen extends StatefulWidget {
  const AudioTestScreen(this.state, {super.key});
  final AppState state;
  @override
  State<AudioTestScreen> createState() => _AudioTestScreenState();
}

class _AudioTestScreenState extends State<AudioTestScreen> {
  AudioDiagnostics? _diagnostics;
  String? _error;
  bool _checking = false;
  Future<void> _check() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final d = await widget.state.audio.diagnostics();
      if (mounted) setState(() => _diagnostics = d);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clips = widget.state.content.words
        .where(
          (w) =>
              w.assetPath != null &&
              widget.state.content.approvedAssets.contains(w.assetPath),
        )
        .toList();
    return LearningPage(
      title: 'Lydtest',
      children: [
        const Text(
          'Lydstatus for prototypen. TTS er syntetisk dansk tale og kan kræve netværk. Offline-garanti gælder kun godkendte lokale optagelser.',
        ),
        FilledButton(
          onPressed: _checking ? null : _check,
          child: Text(
            _checking ? 'Kontrollerer …' : 'Prøv igen: kontrollér dansk stemme',
          ),
        ),
        if (_diagnostics != null)
          Text(
            _diagnostics!.danishAvailable
                ? 'Dansk stemme er tilgængelig'
                : 'Dansk tale er ikke tilgængelig på denne enhed',
          ),
        if (_diagnostics != null) SelectableText(_diagnostics!.detail),
        if (_error != null) SelectableText(_error!),
        const Text('Hele ord · TTS-fallback uden optagelse'),
        for (final word in widget.state.content.words)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(word.text),
              AudioWordButton(widget.state.audio, word),
            ],
          ),
        Text(
          clips.isEmpty
              ? 'Lokal asset-test afventer en reel, lovlig og godkendt ordoptagelse.'
              : 'Godkendte lokale optagelser: ${clips.length}',
        ),
        for (final word in clips) AudioWordButton(widget.state.audio, word),
      ],
    );
  }
}
