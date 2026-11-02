import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/app/app.dart';
import 'package:sprog_appen/features/stavelser_endelser/syllable_screen.dart';

import 'support/fakes.dart';

Future<void> tapText(WidgetTester t, String label) async {
  await t.scrollUntilVisible(find.text(label).hitTestable(), 150);
  await t.tap(find.text(label).hitTestable());
  await t.pumpAndSettle();
}

void main() {
  testWidgets('all eight V3 tasks, wrong answers, retry, result and repeat', (
    t,
  ) async {
    final state = fakeState();
    await t.pumpWidget(SprogApp(state: state));
    await t.pumpAndSettle();
    await tapText(t, 'Åbn ordstruktur');
    for (final l in state.wordStructure!.lessons) {
      await tapText(t, 'Åbn ${l.title.toLowerCase()}');
      await tapText(t, 'Start øvelser');
      final session = state.practiceSession('/ordstruktur', l.id);
      while (!session.finished) {
        final task = state.wordStructure!.task(session.current.id);
        String label(String option) => task.type == 'choose_line_break'
            ? option.replaceFirst('-', '-\n')
            : option;
        if (task.type == 'build_compound') {
          for (final tile in task.tiles) {
            await tapText(t, tile);
          }
          await tapText(t, 'Tjek svar');
          await tapText(t, 'Prøv igen');
          for (final part
              in state.wordStructure!.word(task.exercise.wordId).parts) {
            await tapText(t, part);
          }
          await tapText(t, 'Tjek svar');
        } else {
          await tapText(
            t,
            label(
              task.exercise.options.firstWhere(
                (o) => o != task.exercise.answer,
              ),
            ),
          );
          await tapText(t, 'Prøv igen');
          await tapText(t, label(task.exercise.answer));
        }
        expect(find.text('Ja, det er rigtigt!'), findsOneWidget);
        await tapText(t, 'Næste');
      }
      expect(find.text('Flot øvet!'), findsOneWidget);
      await tapText(t, 'Tilbage til forløbet');
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
    }
    expect(state.progress.stats.values.where((s) => s.completed).length, 8);
    await t.pumpWidget(const SizedBox());
    await state.audio.close();
    state.dispose();
  });
  testWidgets(
    'large text: line breaks display on two lines and unknown route is safe',
    (t) async {
      t.view.physicalSize = const Size(320, 640);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      final state = fakeState();
      await t.pumpWidget(SprogApp(state: state));
      await t.pumpAndSettle();
      await tapText(t, 'Åbn ordstruktur');
      await tapText(t, 'Åbn del ved linjeskift');
      await tapText(t, 'Start øvelser');
      await tapText(t, 'sko-\nle');
      await tapText(t, 'Næste');
      await tapText(t, 'biblioteks-\nbog');
      await tapText(t, 'Næste');
      expect(find.text('Flot øvet!'), findsOneWidget);
      expect(t.takeException(), isNull);
      Navigator.of(t.element(find.byType(SyllableResultScreen)))
          .pushNamed('/ordstruktur/missing/oevelse');
      await t.pumpAndSettle();
      expect(find.text('Siden findes ikke'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await state.audio.close();
      state.dispose();
    },
  );
}
