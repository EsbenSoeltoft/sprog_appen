import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sprog_appen/app/app.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

import 'support/v5_fixture.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'V5 prepare persisted bookmark and level before full process stop',
    (tester) async {
      await backupProgress();
      final p = await readProgress();
      expect(p.warning, isNull);
      await p.record('v4-fill-lege', true);
      await p.record('ex-hest', false);
      await p.record('ex-hest', true);
      await p.setResume(
        const ResumePosition('/udsagnsord', 'v4-skriv-form', 'v4-fill-gaa'),
      );
      p.dispose();
      await tester.pumpWidget(const SprogApp());
      await tester.pumpAndSettle();
      await tapV5(tester, 'Fremskridt');
      await tapV5(tester, 'Uden hjælp');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tapV5(tester, 'Fortsæt forløbet');
      expect(find.text('I går ____ jeg hjem.'), findsOneWidget);
      expect(find.text('Vis hint'), findsNothing);
      // Inspect the actual persisted bytes, not the UI's in-memory state.
      final stored = await readProgress();
      expect(stored.level, PracticeLevel.independent);
      expect(stored.resume!.exerciseId, 'v4-fill-gaa');
      stored.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
