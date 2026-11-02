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
  testWidgets('all V2 tasks: split, build, ending, retry and results', (
    t,
  ) async {
    final state = fakeState();
    await t.pumpWidget(SprogApp(state: state));
    await t.pumpAndSettle();
    await tapText(t, 'Åbn stavelser og endelser');
    for (final l in state.syllables!.lessons) {
      await tapText(t, 'Åbn ${l.title.toLowerCase()}');
      await tapText(t, 'Start øvelser');
      final session = state.syllableSession(l.id);
      while (!session.finished) {
        final task = state.syllables!.task(session.current.id);
        if (task.type == 'build_word') {
          // The tiles are deliberately offered in the wrong order.
          for (final tile in task.tiles) {
            await tapText(t, tile);
          }
          await tapText(t, 'Tjek svar');
          await t.scrollUntilVisible(
            find.textContaining('Godt forsøgt').hitTestable(),
            150,
          );
          expect(find.textContaining('Godt forsøgt'), findsOneWidget);
          await tapText(t, 'Prøv igen');
          for (final tile
              in state.syllables!.word(task.exercise.wordId).syllables) {
            await tapText(t, tile);
          }
          await tapText(t, 'Tjek svar');
        } else {
          final wrong = task.exercise.options.firstWhere(
            (o) => o != task.exercise.answer,
          );
          await tapText(t, task.type == 'choose_ending' ? '-$wrong' : wrong);
          await tapText(t, 'Prøv igen');
          await tapText(
            t,
            task.type == 'choose_ending'
                ? '-${task.exercise.answer}'
                : task.exercise.answer,
          );
        }
        expect(find.text('Ja, det er rigtigt!'), findsOneWidget);
        await tapText(t, 'Næste');
      }
      expect(find.text('Flot øvet!'), findsOneWidget);
      await tapText(t, 'Tilbage til forløbet');
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
    }
    expect(state.progress.stats.values.where((s) => s.completed).length, 6);
    await t.pumpWidget(const SizedBox());
    await state.audio.close();
    state.dispose();
  });
  testWidgets(
    'large text, back preserves feedback and unknown V2 route is safe',
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
      await tapText(t, 'Åbn stavelser og endelser');
      await tapText(t, 'Åbn find endelsen');
      await tapText(t, 'Start øvelser');
      await tapText(t, '-e');
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
      await tapText(t, 'Start øvelser');
      await t.scrollUntilVisible(
        find.textContaining('Godt forsøgt').hitTestable(),
        150,
      );
      expect(find.textContaining('Godt forsøgt'), findsOneWidget);
      await tapText(t, 'Prøv igen');
      await tapText(t, '-er');
      await tapText(t, 'Næste');
      expect(t.takeException(), isNull);
      Navigator.of(t.element(find.byType(SyllableExerciseScreen)))
          .pushNamed('/stavelser/missing/oevelse');
      await t.pumpAndSettle();
      expect(find.text('Siden findes ikke'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await state.audio.close();
      state.dispose();
    },
  );
}
