import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../lydtrappen/logic/exercise_controller.dart';
import '../../shared/widgets/learning_page.dart';
import '../audio/audio_word_button.dart';
import 'data/syllable_repository.dart';
import '../udsagnsord/verb_repository.dart';
import '../udsagnsord/verb_reference.dart';
import '../progress/progress_repository.dart';

class SyllableOverviewScreen extends StatelessWidget {
  const SyllableOverviewScreen(
    this.state, {
    super.key,
    this.modulePath = '/stavelser',
  });
  final AppState state;
  final String modulePath;
  @override
  Widget build(BuildContext context) {
    final data = state.practiceContent(modulePath);
    if (data == null) {
      return LearningPage(
        title: modulePath == '/udsagnsord'
            ? 'Udsagnsord'
            : modulePath == '/ordstruktur'
            ? 'Sammensatte ord og orddeling'
            : 'Stavelser og endelser',
        children: [Text('Indholdet er ikke tilgængeligt lige nu.')],
      );
    }
    return LearningPage(
      title: modulePath == '/udsagnsord'
          ? 'Udsagnsord'
          : modulePath == '/ordstruktur'
          ? 'Sammensatte ord og orddeling'
          : 'Stavelser og endelser',
      children: [
        Text(
          modulePath == '/udsagnsord'
              ? 'Se hvordan udsagnsord ændrer form. Vælg et forløb eller læs bøjningsskemaerne nedenfor.'
              : modulePath == '/ordstruktur'
              ? 'Betydningsdele er ordets led. Stavelser handler om ordets lydlige opbygning. Deling ved linjeskift er et tredje, særskilt spørgsmål.'
              : 'Et ord kan have flere stavelser. En endelse kan vise, at vi taler om flere ting. Stavelser og grammatiske endelser er ikke det samme.',
        ),
        Text(
          modulePath == '/udsagnsord'
              ? 'Eksempler og syntetisk tale afventer faglig godkendelse.'
              : modulePath == '/ordstruktur'
              ? 'Vælg et af de fire forløb. Alle eksempler afventer faglig godkendelse.'
              : 'Eksemplerne er en prototype og afventer godkendelse. Vi træner stavelser her, ikke regler for orddeling ved linjeskift.',
        ),
        for (final lesson in data.lessons)
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(lesson.description),
                  const SizedBox(height: 12),
                  SyllableProgress(state, lesson, modulePath: modulePath),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '$modulePath/${lesson.id}',
                    ),
                    child: Text('Åbn ${lesson.title.toLowerCase()}'),
                  ),
                ],
              ),
            ),
          ),
        if (modulePath == '/udsagnsord') VerbReference(state),
      ],
    );
  }
}

class SyllableLessonScreen extends StatelessWidget {
  const SyllableLessonScreen(
    this.state,
    this.lesson, {
    super.key,
    this.modulePath = '/stavelser',
  });
  final AppState state;
  final String modulePath;
  final SyllableLesson lesson;
  @override
  Widget build(BuildContext context) {
    final data = state.practiceContent(modulePath)!;
    final words = lesson.exerciseIds
        .map((id) => data.word(data.task(id).exercise.wordId))
        .toList();
    return LearningPage(
      title: lesson.title,
      children: [
        Text(lesson.description),
        Text(
          modulePath == '/udsagnsord'
              ? 'Læs og lyt til korte sætninger. Du kan løse øvelserne uden lyd.'
              : 'Lyt til hele ordet, eller brug teksten. Lyden af enkelte stavelser og endelser kommer senere med godkendte optagelser.',
        ),
        for (final w in words)
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.text,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (w.syllables.isNotEmpty &&
                      [
                        'choose_syllables',
                        'build_word',
                      ].contains(data.task(lesson.exerciseIds.first).type))
                    Semantics(
                      label: 'Stavelser: ${w.syllables.join(', ')}',
                      child: Text(w.syllables.join(' · ')),
                    ),
                  if (w.ending != null)
                    Text('Stamme: ${w.stem} · endelse: -${w.ending}'),
                  if (w.parts.isNotEmpty &&
                      [
                        'build_compound',
                        'choose_parts',
                      ].contains(data.task(lesson.exerciseIds.first).type))
                    Text(
                      'Betydningsdele: ${w.parts.join(' + ')}${w.linkingElement.isEmpty ? '' : ' · bindebogstav: ${w.linkingElement}'}',
                    ),
                  if (data.task(lesson.exerciseIds.first).type ==
                      'choose_line_break') ...[
                    const Text('Ved linjeskift, fx:'),
                    Text(w.lineBreaks.first.replaceFirst('-', '-\n')),
                  ],
                  Text(w.explanation),
                  AudioWordButton(
                    state.audio,
                    w,
                    label: modulePath == '/udsagnsord'
                        ? 'Hør sætningen'
                        : 'Hør ordet',
                  ),
                ],
              ),
            ),
          ),
        FilledButton(
          onPressed: () {
            final s = state.practiceSession(modulePath, lesson.id);
            if (s.finished) s.restart();
            Navigator.pushNamed(context, '$modulePath/${lesson.id}/oevelse');
          },
          child: const Text('Start øvelser'),
        ),
      ],
    );
  }
}

class SyllableExerciseScreen extends StatefulWidget {
  const SyllableExerciseScreen(
    this.state,
    this.lesson, {
    super.key,
    this.modulePath = '/stavelser',
  });
  final AppState state;
  final String modulePath;
  final SyllableLesson lesson;
  @override
  State<SyllableExerciseScreen> createState() => _SyllableExerciseScreenState();
}

class _SyllableExerciseScreenState extends State<SyllableExerciseScreen> {
  ExerciseController get session =>
      widget.state.practiceSession(widget.modulePath, widget.lesson.id);
  final List<int> _selected = [];
  bool _showHint = false;
  final _answer = TextEditingController();
  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) {
      final data = widget.state.practiceContent(widget.modulePath)!;
      final e = session.current;
      final t = data.task(e.id);
      final w = data.word(e.wordId);
      return LearningPage(
        title:
            '${widget.lesson.title} · ${session.index + 1}/${session.exercises.length}',
        children: [
          Text(t.prompt, style: Theme.of(context).textTheme.titleLarge),
          if (e.maskedText.isNotEmpty)
            Text(
              e.maskedText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          if (w.context != null)
            Text(w.context!, style: Theme.of(context).textTheme.headlineSmall),
          AudioWordButton(
            widget.state.audio,
            w,
            key: ValueKey(e.id),
            label: widget.modulePath == '/udsagnsord'
                ? 'Hør sætningen'
                : 'Hør ordet',
          ),
          if (widget.state.progress.level == PracticeLevel.supported &&
              session.correct == null) ...[
            TextButton(
              onPressed: () => setState(() => _showHint = !_showHint),
              child: Text(_showHint ? 'Skjul hint' : 'Vis hint'),
            ),
            if (_showHint) Text('Hjælp: ${e.answer}. ${w.explanation}'),
          ],
          if (t.type == 'fill_form') ...[
            TextField(
              key: ValueKey('answer-${e.id}'),
              controller: _answer,
              enabled: session.correct == null,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                labelText: 'Skriv formen her',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) => session.submit(
                normaliseVerbAnswer(value),
                allowFreeText: true,
              ),
            ),
            FilledButton(
              onPressed: session.correct != null || _answer.text.trim().isEmpty
                  ? null
                  : () => session.submit(
                      normaliseVerbAnswer(_answer.text),
                      allowFreeText: true,
                    ),
              child: const Text('Tjek svar'),
            ),
          ] else if (t.type == 'build_word' || t.type == 'build_compound') ...[
            Semantics(
              liveRegion: true,
              child: Text(
                _selected.isEmpty
                    ? 'Dit ord: …'
                    : 'Dit ord: ${_selected.map((i) => t.tiles[i]).join(' · ')}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < t.tiles.length; i++)
                  FilledButton(
                    onPressed: session.correct != null || _selected.contains(i)
                        ? null
                        : () => setState(() => _selected.add(i)),
                    child: Text(t.tiles[i]),
                  ),
              ],
            ),
            TextButton(
              onPressed: _selected.isEmpty || session.correct != null
                  ? null
                  : () => setState(_selected.clear),
              child: const Text('Ryd dit ord'),
            ),
            FilledButton(
              onPressed:
                  _selected.length != t.tiles.length || session.correct != null
                  ? null
                  : () =>
                        session.submit(_selected.map((i) => t.tiles[i]).join()),
              child: const Text('Tjek svar'),
            ),
          ] else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final option in e.options)
                  FilledButton(
                    onPressed: session.correct != null
                        ? null
                        : () => session.submit(option),
                    child: Text(
                      t.type == 'choose_ending'
                          ? '-$option'
                          : t.type == 'choose_line_break'
                          ? option.replaceFirst('-', '-\n')
                          : option,
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
                  Text(w.explanation),
                  if (t.type == 'choose_ending')
                    Text(
                      'Her er ordet ${w.text}. Stamme og endelse: ${w.stem} + ${w.ending}.',
                    ),
                ],
              ),
            ),
          if (session.correct == false)
            FilledButton(
              onPressed: () {
                session.retry();
                setState(() {
                  _selected.clear();
                  _answer.clear();
                  _showHint = false;
                });
              },
              child: const Text('Prøv igen'),
            ),
          if (session.correct == true)
            FilledButton(
              onPressed: () {
                unawaited(widget.state.audio.stop());
                FocusManager.instance.primaryFocus?.unfocus();
                _answer.clear();
                _showHint = false;
                session.next();
                setState(_selected.clear);
                if (session.finished) {
                  Navigator.pushReplacementNamed(
                    context,
                    '${widget.modulePath}/${widget.lesson.id}/resultat',
                  );
                }
              },
              child: const Text('Næste'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tilbage til forløbet'),
          ),
        ],
      );
    },
  );
}

class SyllableProgress extends StatelessWidget {
  const SyllableProgress(
    this.state,
    this.lesson, {
    super.key,
    this.modulePath = '/stavelser',
  });
  final AppState state;
  final String modulePath;
  final SyllableLesson lesson;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state.progress,
    builder: (context, _) {
      final done = lesson.exerciseIds
          .where((id) => state.progress.stats[id]?.completed ?? false)
          .toList();
      final first = done
          .where((id) => state.progress.stats[id]!.firstAttemptCorrect)
          .length;
      return Text(
        'Gennemført: ${done.length} / ${lesson.exerciseIds.length}\nRigtige første forsøg: $first / ${done.length}',
      );
    },
  );
}

class SyllableResultScreen extends StatelessWidget {
  const SyllableResultScreen(
    this.state,
    this.lesson, {
    super.key,
    this.modulePath = '/stavelser',
  });
  final AppState state;
  final String modulePath;
  final SyllableLesson lesson;
  @override
  Widget build(BuildContext context) => LearningPage(
    title: 'Flot øvet!',
    children: [
      Text(lesson.title, style: Theme.of(context).textTheme.headlineSmall),
      SyllableProgress(state, lesson, modulePath: modulePath),
      const Text(
        'Du har øvet orddele. Du må gerne gentage forløbet i dit eget tempo.',
      ),
      FilledButton(
        onPressed: () {
          state.practiceSession(modulePath, lesson.id).restart();
          Navigator.pushReplacementNamed(
            context,
            '$modulePath/${lesson.id}/oevelse',
          );
        },
        child: const Text('Start igen'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Tilbage til forløbet'),
      ),
    ],
  );
}
