import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/home/home_screen.dart';
import '../features/lydtrappen/data/lesson_repository.dart';
import '../features/lydtrappen/lydtrappen_screen.dart';
import '../features/audio/learning_audio_service.dart';
import '../features/progress/progress_repository.dart';
import 'app_state.dart';
import '../features/udsagnsord/verb_repository.dart';
import '../shared/widgets/learning_page.dart';
import '../features/stavelser_endelser/data/syllable_repository.dart';
import '../features/stavelser_endelser/syllable_screen.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

class SprogApp extends StatefulWidget {
  const SprogApp({super.key, this.state, this.loadState});
  final AppState? state;
  final Future<AppState> Function()? loadState;
  @override
  State<SprogApp> createState() => _SprogAppState();
}

class _SprogAppState extends State<SprogApp> with WidgetsBindingObserver {
  AppState? _state;
  Object? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final supplied = widget.state;
      if (supplied != null) {
        setState(() => _state = supplied);
        return;
      }
      if (widget.loadState != null) {
        final loaded = await widget.loadState!();
        if (mounted) {
          setState(() => _state = loaded);
        } else {
          await loaded.audio.close();
          loaded.dispose();
        }
        return;
      }
      final content = await LessonRepository().load();
      final syllables = await SyllableRepository().load();
      final wordStructure = await WordStructureRepository().load();
      final verbs = await VerbRepository().load();
      final progress = ProgressRepository(PreferencesProgressStore());
      await progress.load({
        ...content.exercises.map((e) => e.id),
        ...syllables.exerciseIds,
        ...wordStructure.exerciseIds,
        ...verbs.practice.exerciseIds,
      });
      if (!mounted) {
        progress.dispose();
        return;
      }
      setState(
        () => _state = AppState(
          content,
          progress,
          LearningAudioService(DeviceAudioBackend(), content.approvedAssets),
          syllables: syllables,
          wordStructure: wordStructure,
          verbs: verbs,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_state?.audio.stop());
      unawaited(_state?.progress.flush());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.state == null && _state != null) {
      unawaited(_state!.audio.close());
      _state!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(seedColor: const Color(0xFF24685B));
    return MaterialApp(
      key: ValueKey(_state != null),
      title: 'Sprog Appen',
      debugShowCheckedModeBanner: false,
      locale: const Locale('da', 'DK'),
      supportedLocales: const [Locale('da', 'DK')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        scaffoldBackgroundColor: const Color(0xFFF8F9F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9F5),
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
      ),
      navigatorObservers: [routeObserver],
      onGenerateRoute: (settings) {
        // Resolve once per route, so rebuilds do not reset an active exercise.
        final screen = _state == null
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : _screen(settings.name ?? '/');
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => _state == null
              ? screen
              : _AudioRouteScope(audio: _state!.audio, child: screen),
        );
      },
      // Rebuild the route content once asynchronous startup finishes.
      builder: (context, child) => _state == null
          ? (_error == null
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : Scaffold(
                    body: Center(
                      child: FilledButton(
                        onPressed: _load,
                        child: const Text(
                          'Indhold kunne ikke åbnes. Prøv igen',
                        ),
                      ),
                    ),
                  ))
          : child!,
    );
  }

  Widget _screen(String route) {
    final state = _state!;
    final parts = Uri.tryParse(route)?.pathSegments ?? [];
    if (route == '/') return HomeScreen(state: state);
    if (route == '/lydtrappe') return const LydtrappenScreen();
    if (route == '/lydtrappe/vokaler') return VowelOverviewScreen(state);
    if (route == '/stavelser' ||
        route == '/ordstruktur' ||
        route == '/udsagnsord') {
      return SyllableOverviewScreen(state, modulePath: route);
    }
    if (parts.length >= 2 &&
        ['stavelser', 'ordstruktur', 'udsagnsord'].contains(parts.first)) {
      final path = '/${parts.first}';
      final lessons = state
          .practiceContent(path)
          ?.lessons
          .where((l) => l.id == parts[1]);
      if (lessons != null && lessons.isNotEmpty) {
        final lesson = lessons.first;
        if (parts.length == 2) {
          return SyllableLessonScreen(state, lesson, modulePath: path);
        }
        if (parts.length == 3 && parts[2] == 'oevelse') {
          unawaited(state.practiceSession(path, lesson.id).visit());
          return SyllableExerciseScreen(state, lesson, modulePath: path);
        }
        if (parts.length == 3 && parts[2] == 'resultat') {
          return SyllableResultScreen(state, lesson, modulePath: path);
        }
      }
    }
    if (route == '/fremskridt') return ProgressScreen(state);
    if (route == '/indstillinger/lydtest') return AudioTestScreen(state);
    if (parts.length == 3 && parts.first == 'lydtrappe') {
      final id = parts[2];
      if (parts[1] == 'vokaler' || parts[1] == 'resultat') {
        final matches = state.content.ladders.where((l) => l.id == id);
        if (matches.isNotEmpty) {
          return parts[1] == 'vokaler'
              ? LadderDetailScreen(state, matches.first)
              : ResultScreen(state, matches.first);
        }
      }
      if (parts[1] == 'oevelse') {
        final matches = state.content.exercises.where((e) => e.id == id);
        if (matches.isNotEmpty) {
          final e = matches.first;
          final session = state.session(state.content.word(e.wordId).ladderId);
          if (session.current.id != id) {
            session.index = session.exercises.indexWhere(
              (item) => item.id == id,
            );
            session.correct = null;
            session.finished = false;
          }
          // A session is retained across normal back navigation.
          unawaited(session.visit());
          return WordExerciseScreen(state, session);
        }
      }
    }
    return LearningPage(
      title: 'Siden findes ikke',
      children: [
        const Text('Vi kunne ikke finde denne trappe eller øvelse.'),
        Builder(
          builder: (context) => FilledButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            child: const Text('Til forsiden'),
          ),
        ),
      ],
    );
  }
}

class _AudioRouteScope extends StatefulWidget {
  const _AudioRouteScope({required this.audio, required this.child});
  final LearningAudioService audio;
  final Widget child;
  @override
  State<_AudioRouteScope> createState() => _AudioRouteScopeState();
}

class _AudioRouteScopeState extends State<_AudioRouteScope> with RouteAware {
  ModalRoute<void>? _route;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of<void>(context);
    if (route != _route) {
      routeObserver.unsubscribe(this);
      _route = route;
      if (route != null) routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    unawaited(widget.audio.stop());
  }

  @override
  void didPop() {
    unawaited(widget.audio.stop());
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
