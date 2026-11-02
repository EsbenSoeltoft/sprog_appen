import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/app/app.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';
import 'package:sprog_appen/features/stavelser_endelser/syllable_screen.dart';

import 'support/fakes.dart';

Future<void> tap(WidgetTester t, String text) async {
  if (find.text(text).evaluate().isNotEmpty) {
    await t.ensureVisible(find.text(text));
    await t.pumpAndSettle();
  }
  await t.scrollUntilVisible(
    find.text(text).hitTestable(),
    150,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 100,
  );
  await t.tap(find.text(text).hitTestable());
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'continue reopens saved question and independent mode hides hints',
    (t) async {
      final state = fakeState();
      await state.progress.setLevel(PracticeLevel.independent);
      await state.progress.setResume(
        const ResumePosition('/udsagnsord', 'v4-skriv-form', 'v4-fill-gaa'),
      );
      await t.pumpWidget(SprogApp(state: state));
      await t.pumpAndSettle();
      await tap(t, 'Fortsæt forløbet');
      expect(find.text('I går ____ jeg hjem.'), findsOneWidget);
      expect(find.text('Vis hint'), findsNothing);
      await t.pumpWidget(const SizedBox());
      await state.progress.flush();
      await state.audio.close();
      state.dispose();
    },
  );
  testWidgets('support choice persists and reveals an explicit hint', (
    t,
  ) async {
    final state = fakeState();
    await t.pumpWidget(SprogApp(state: state));
    await t.pumpAndSettle();
    await tap(t, 'Fremskridt');
    await tap(t, 'Uden hjælp');
    expect(state.progress.level, PracticeLevel.independent);
    await tap(t, 'Med hjælp');
    Navigator.of(t.element(find.byType(Scaffold)))
        .pushNamed('/udsagnsord/v4-skriv-form/oevelse');
    await t.pumpAndSettle();
    await tap(t, 'Vis hint');
    expect(find.textContaining('Hjælp: legede.'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await state.progress.flush();
    await state.audio.close();
    state.dispose();
  });
  testWidgets(
    'recommendation opens reviewed task; reset removes bookmark and history',
    (t) async {
      final state = fakeState();
      await state.progress.record('v3-line-skole', false);
      await state.progress.record('v3-line-skole', true);
      await t.pumpWidget(SprogApp(state: state));
      await t.pumpAndSettle();
      await tap(t, 'Fremskridt');
      await tap(t, 'Øv denne opgave');
      expect(find.byType(SyllableExerciseScreen), findsOneWidget);
      expect(find.textContaining('Ordet skole skal deles'), findsOneWidget);
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
      await tap(t, 'Nulstil fremskridt');
      await tap(t, 'Nulstil');
      await state.progress.flush();
      expect(state.progress.resume, isNull);
      expect(state.progress.stats, isEmpty);
      expect(state.progress.level, PracticeLevel.supported);
      await t.pumpWidget(const SizedBox());
      await state.audio.close();
      state.dispose();
    },
  );
  testWidgets('dashboard fits narrow screen with double text', (t) async {
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final state = fakeState();
    await t.pumpWidget(SprogApp(state: state));
    await t.pumpAndSettle();
    await tap(t, 'Fremskridt');
    await tap(t, 'Uden hjælp');
    await tap(t, 'Med hjælp');
    await tap(t, 'Øv denne opgave');
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await state.progress.flush();
    await state.audio.close();
    state.dispose();
  });
}
