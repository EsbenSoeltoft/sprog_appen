import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sprog_appen/app/app.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

import 'support/v5_fixture.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'V5 bookmark and help level survive a forced Android process restart',
    (tester) async {
      try {
        final p = await readProgress();
        expect(p.level, PracticeLevel.independent);
        expect(p.stats['v4-fill-lege']!.completed, true);
        expect(p.stats['ex-hest']!.reviewNeeded, true);
        expect(p.stats['ex-hest']!.totalAttempts, greaterThanOrEqualTo(2));
        expect(p.resume!.exerciseId, 'v4-fill-gaa');
        p.dispose();
        await tester.pumpWidget(const SprogApp());
        await tester.pumpAndSettle();
        await tapV5(tester, 'Fortsæt forløbet');
        expect(find.text('I går ____ jeg hjem.'), findsOneWidget);
        expect(find.text('Vis hint'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      } finally {
        await restoreProgress();
      }
    },
  );
}
