import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import 'progress_repository.dart';

class LearningDashboard extends StatelessWidget {
  const LearningDashboard(this.state, {super.key, this.compact = false});
  final AppState state;
  final bool compact;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state.progress,
    builder: (context, _) {
      final resume = state.resumeTarget, recommendation = state.recommendation;
      final done = state.targets
          .where((t) => state.progress.stats[t.exerciseId]?.completed ?? false)
          .length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            Text(
              'Din fremgang',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '$done / ${state.targets.length} opgaver gennemført · ${state.completedLessons} forløb gennemført',
            ),
            const SizedBox(height: 12),
            Text('Vælg støtte', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final level in PracticeLevel.values)
                  OutlinedButton.icon(
                    onPressed: () => state.progress.setLevel(level),
                    icon: Icon(
                      state.progress.level == level
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                    label: Text(
                      level == PracticeLevel.supported
                          ? 'Med hjælp'
                          : 'Uden hjælp',
                    ),
                  ),
              ],
            ),
            const Text(
              'Med hjælp kan du vise et hint. Uden hjælp løser du samme opgaver uden hint. Du kan skifte når som helst; din historik bevares.',
            ),
          ],
          if (resume != null)
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fortsæt, hvor du slap',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(resume.title),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        state.openTarget(resume, resume: true),
                      ),
                      child: const Text('Fortsæt forløbet'),
                    ),
                  ],
                ),
              ),
            ),
          if (!compact && recommendation != null)
            Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forslag til næste øvelse',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(recommendation.title),
                    Text(state.recommendationReason(recommendation)),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        state.openTarget(recommendation),
                      ),
                      child: const Text('Øv denne opgave'),
                    ),
                  ],
                ),
              ),
            ),
          if (state.progress.warning != null) Text(state.progress.warning!),
        ],
      );
    },
  );
}
