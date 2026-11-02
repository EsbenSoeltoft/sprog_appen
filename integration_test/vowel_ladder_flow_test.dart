import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sprog_appen/app/app.dart';

import 'support/v5_fixture.dart';

import 'package:sprog_appen/features/udsagnsord/verb_repository.dart';
import 'package:sprog_appen/features/stavelser_endelser/data/syllable_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('real Android exercise, progress reload and diagnostics', (
    tester,
  ) async {
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
    Future<void> tap(String label) async {
      await tester.scrollUntilVisible(
        find.text(label).hitTestable(),
        150,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 100,
      );
      await tester.tap(find.text(label).hitTestable());
      await tester.pumpAndSettle();
    }

    await tap('Åbn lydtrappen');
    await tap('Vokaltrappen');
    await tap('Se ord: y – ø');
    await tap('Start øvelser');
    await tap('y');
    await tap('Næste');
    expect(find.text('Flot øvet!'), findsOneWidget);
    // Native audio and persistence must also be reviewed manually per the plan.
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SprogApp());
    await tester.pumpAndSettle();
    await tap('Fremskridt');
    Navigator.of(tester.element(find.byType(Scaffold)))
        .pushNamed('/lydtrappe/resultat/y-oe');
    await tester.pumpAndSettle();
    expect(find.textContaining('Gennemført: 1 / 1'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tap('Åbn stavelser og endelser');
    await tap('Åbn find stavelserne');
    await tap('Start øvelser');
    await tap('ka-ge');
    await tap('Næste');
    await tap('sko-le');
    await tap('Næste');
    expect(find.text('Flot øvet!'), findsOneWidget);
    await tap('Tilbage til forløbet');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tap('Åbn byg med stavelser');
    await tap('Start øvelser');
    await tap('sko');
    await tap('le');
    await tap('Tjek svar');
    await tap('Næste');
    await tap('ka');
    await tap('ge');
    await tap('Tjek svar');
    await tap('Næste');
    expect(find.text('Flot øvet!'), findsOneWidget);
    await tap('Tilbage til forløbet');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tap('Åbn find endelsen');
    await tap('Start øvelser');
    await tap('-er');
    await tap('Næste');
    await tap('-e');
    await tap('Næste');
    expect(find.text('Flot øvet!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SprogApp());
    await tester.pumpAndSettle();
    await tap('Fremskridt');
    await tester.scrollUntilVisible(
      find.text('Find endelsen').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 100,
    );
    final progressContext = tester.element(find.byType(Scaffold));
    Navigator.of(progressContext)
        .pushNamed('/stavelser/v2-find-endelsen/resultat');
    await tester.pumpAndSettle();
    expect(find.textContaining('Gennemført: 2 / 2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SprogApp());
    await tester.pumpAndSettle();
    final structure = await WordStructureRepository().load();
    await tap('Åbn ordstruktur');
    for (final lesson in structure.lessons) {
      await tap('Åbn ${lesson.title.toLowerCase()}');
      await tap('Start øvelser');
      for (final id in lesson.exerciseIds) {
        final task = structure.task(id);
        if (task.type == 'build_compound') {
          for (final part in structure.word(task.exercise.wordId).parts) {
            await tap(part);
          }
          await tap('Tjek svar');
        } else {
          await tap(
            task.type == 'choose_line_break'
                ? task.exercise.answer.replaceFirst('-', '-\n')
                : task.exercise.answer,
          );
        }
        expect(find.text('Ja, det er rigtigt!'), findsOneWidget);
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
        .pushNamed('/ordstruktur/v3-linjeskift/resultat');
    await tester.pumpAndSettle();
    expect(find.textContaining('Gennemført: 2 / 2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SprogApp());
    await tester.pumpAndSettle();
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
          await tester.enterText(find.byType(TextField), task.exercise.answer);
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
        expect(find.text('Ja, det er rigtigt!'), findsOneWidget);
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
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SprogApp());
    await tester.pumpAndSettle();
    await tap('Lydtest');
    await tap('Prøv igen: kontrollér dansk stemme');
    expect(find.textContaining('Dansk'), findsWidgets);
  });
}
