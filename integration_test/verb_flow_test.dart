import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sprog_appen/app/app.dart';

import 'support/v5_fixture.dart';

import 'package:sprog_appen/features/udsagnsord/verb_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native V4 keyboard across consecutive exercises and progress reload',
    (tester) async {
      await backupProgress();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await restoreProgress();
      });
      final initialProgress = await readProgress();
      await initialProgress.setResume(null);
      initialProgress.dispose();
      await tester.pumpWidget(const SprogApp());
      await tester.pumpAndSettle();
      Future<void> tap(String text) async {
        await tester.scrollUntilVisible(
          find.text(text).hitTestable(),
          150,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 100,
        );
        await tester.tap(find.text(text).hitTestable());
        await tester.pumpAndSettle();
      }

      final verbs = await VerbRepository().load();
      await tap('Åbn udsagnsord');
      for (final lesson in verbs.practice.lessons) {
        await tap('Åbn ${lesson.title.toLowerCase()}');
        await tap('Start øvelser');
        for (final id in lesson.exerciseIds) {
          final task = verbs.practice.task(id);
          if (task.type == 'fill_form') {
            await tester.scrollUntilVisible(
              find.byType(TextField).hitTestable(),
              150,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.enterText(
              find.byType(TextField),
              task.exercise.answer,
            );
            await tester.pumpAndSettle();
            expect(
              tester.widget<TextField>(find.byType(TextField)).controller!.text,
              task.exercise.answer,
              reason: id,
            );
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.pumpAndSettle();
            await tap('Tjek svar');
          } else {
            await tap(task.exercise.answer);
          }
          await tester.scrollUntilVisible(
            find.text('Ja, det er rigtigt!').hitTestable(),
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tap('Næste');
        }
        expect(find.text('Flot øvet!'), findsOneWidget);
        await tap('Tilbage til forløbet');
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SprogApp());
      await tester.pumpAndSettle();
      await tap('Fremskridt');
      Navigator.of(tester.element(find.byType(Scaffold)))
          .pushNamed('/udsagnsord/v4-find-tid/resultat');
      await tester.pumpAndSettle();
      expect(find.textContaining('Gennemført: 4 / 4'), findsOneWidget);
    },
  );
}
