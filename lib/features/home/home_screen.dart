import 'package:flutter/material.dart';

import '../../app/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.state});
  final AppState? state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sprog Appen')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Et lille skridt ad gangen',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Se, hør og øv det danske sprog. Her er der plads til at gentage og tage sig god tid.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                ListenableBuilder(
                  listenable:
                      state?.progress ?? const AlwaysStoppedAnimation(0),
                  builder: (context, _) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (state?.resumeTarget != null)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            state!.openTarget(
                              state!.resumeTarget!,
                              resume: true,
                            ),
                          ),
                          child: const Text('Fortsæt forløbet'),
                        ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/fremskridt'),
                        child: const Text('Fremskridt'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/indstillinger/lydtest',
                        ),
                        child: const Text('Lydtest'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card.filled(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.hearing_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lydtrappen',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Det første forløb handler om at lytte til sprogets lyde.',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prototype · seks ordøvelser klar til afprøvning',
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/lydtrappe'),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Åbn lydtrappen'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stavelser og endelser',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Del ord i stavelser, byg ord og find endelser i korte sætninger.',
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/stavelser'),
                          child: const Text('Åbn stavelser og endelser'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sammensatte ord og orddeling',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Byg ord, find betydningsdele og stavelser, og øv deling ved linjeskift.',
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/ordstruktur'),
                          child: const Text('Åbn ordstruktur'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Udsagnsord',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Se bøjningsskemaer, vælg former, skriv svar og genkend navneform og tider.',
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/udsagnsord'),
                          child: const Text('Åbn udsagnsord'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Fra Incipier · Ingen konto, reklamer eller tracking',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
