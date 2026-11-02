import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/app/app.dart';
import 'package:sprog_appen/features/stavelser_endelser/syllable_screen.dart';

import 'support/fakes.dart';

Future<void> tap(WidgetTester t, String label) async {
  await t.scrollUntilVisible(
    find.text(label).hitTestable(),
    150,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 100,
  );
  await t.tap(find.text(label).hitTestable());
  await t.pumpAndSettle();
}

Future<void> write(WidgetTester t, String value) async {
  await t.scrollUntilVisible(
    find.byType(TextField).hitTestable(),
    150,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 100,
  );
  await t.enterText(find.byType(TextField), value);
  t.testTextInput.hide();
  await t.pumpAndSettle();
  await tap(t, 'Tjek svar');
}

void main() {
  testWidgets('all ten verb exercises, free-text retry, labels and results', (
    t,
  ) async {
    final state = fakeState();
    await t.pumpWidget(SprogApp(state: state));
    await t.pumpAndSettle();
    await tap(t, 'Åbn udsagnsord');
    for (final l in state.verbs!.practice.lessons) {
      await tap(t, 'Åbn ${l.title.toLowerCase()}');
      await tap(t, 'Start øvelser');
      final session = state.practiceSession('/udsagnsord', l.id);
      while (!session.finished) {
        final task = state.verbs!.practice.task(session.current.id);
        if (task.type == 'fill_form') {
          await write(t, 'forkert');
          await tap(t, 'Prøv igen');
          await write(t, '  ${task.exercise.answer.toUpperCase()}  ');
        } else {
          await tap(
            t,
            task.exercise.options.firstWhere((o) => o != task.exercise.answer),
          );
          await tap(t, 'Prøv igen');
          await tap(t, task.exercise.answer);
        }
        expect(find.text('Ja, det er rigtigt!'), findsOneWidget);
        await tap(t, 'Næste');
      }
      expect(find.text('Flot øvet!'), findsOneWidget);
      await tap(t, 'Tilbage til forløbet');
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
    }
    expect(state.progress.stats.values.where((s) => s.completed).length, 10);
    await t.pumpWidget(const SizedBox());
    await state.audio.close();
    state.dispose();
  });
  testWidgets('large text: verb references and typed exercise remain usable', (
    t,
  ) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = fakeState();
    await t.pumpWidget(SprogApp(state: state));
    await t.pumpAndSettle();
    await tap(t, 'Åbn udsagnsord');
    await tap(t, 'at være');
    await t.scrollUntilVisible(
      find.text('førnutid: har været').hitTestable(),
      250,
    );
    expect(t.takeException(), isNull);
    // Direct route avoids a long reverse scroll through the reference list.
    Navigator.of(t.element(find.byType(Scaffold)))
        .pushNamed('/udsagnsord/v4-skriv-form/oevelse');
    await t.pumpAndSettle();
    await write(t, 'legede');
    await tap(t, 'Næste');
    expect(t.takeException(), isNull);
    Navigator.of(t.element(find.byType(SyllableExerciseScreen)))
        .pushNamed('/udsagnsord/missing/oevelse');
    await t.pumpAndSettle();
    expect(find.text('Siden findes ikke'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await state.audio.close();
    state.dispose();
  });
}
