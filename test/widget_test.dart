import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprog_appen/app/app.dart';
import 'package:sprog_appen/features/lydtrappen/lydtrappen_screen.dart';

import 'support/fakes.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(find.text(text).hitTestable(), 150);
  await tester.tap(find.text(text).hitTestable());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('all six exercises, feedback, back state and result', (
    tester,
  ) async {
    final state = fakeState();
    await tester.pumpWidget(SprogApp(state: state));
    await tester.pumpAndSettle();
    await tapText(tester, 'Åbn lydtrappen');
    await tapText(tester, 'Vokaltrappen');
    for (final ladder in state.content.ladders) {
      await tapText(tester, 'Se ord: ${ladder.label}');
      await tapText(tester, 'Start øvelser');
      final session = state.session(ladder.id);
      final first = session.current;
      await tapText(tester, first.options.firstWhere((v) => v != first.answer));
      expect(find.textContaining('Godt forsøgt'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tapText(tester, 'Start øvelser');
      expect(find.textContaining('Godt forsøgt'), findsOneWidget);
      await tapText(tester, 'Prøv igen');
      while (!session.finished) {
        await tapText(tester, session.current.answer);
        expect(find.text('Ja, det er rigtigt!'), findsOneWidget);
        await tapText(tester, 'Næste');
      }
      expect(find.text('Flot øvet!'), findsOneWidget);
      await tapText(tester, 'Tilbage til trappen');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }
    expect(state.progress.stats.values.where((s) => s.completed).length, 6);
    await tester.pumpWidget(const SizedBox());
    await state.audio.close();
    state.dispose();
  });
  testWidgets('small screen and doubled text; friendly unknown route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final state = fakeState();
    await tester.pumpWidget(SprogApp(state: state));
    await tester.pumpAndSettle();
    await tapText(tester, 'Åbn lydtrappen');
    await tapText(tester, 'Vokaltrappen');
    await tapText(tester, 'Se ord: i – e – æ – a');
    await tapText(tester, 'Start øvelser');
    await tapText(tester, 'Vis læsehjælp uden lyd');
    expect(find.text('Find vokalen i: hest'), findsOneWidget);
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.byType(WordExerciseScreen)))
        .pushNamed('/lydtrappe/vokaler/missing');
    await tester.pumpAndSettle();
    expect(find.text('Siden findes ikke'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await state.audio.close();
    state.dispose();
  });
  testWidgets('progress reset requires explicit confirmation', (tester) async {
    final state = fakeState();
    await state.progress.record('ex-hest', true);
    await tester.pumpWidget(SprogApp(state: state));
    await tester.pumpAndSettle();
    await tapText(tester, 'Fremskridt');
    await tapText(tester, 'Nulstil fremskridt');
    await tapText(tester, 'Behold');
    expect(state.progress.stats, isNotEmpty);
    await tapText(tester, 'Nulstil fremskridt');
    await tapText(tester, 'Nulstil');
    expect(state.progress.stats, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await state.audio.close();
    state.dispose();
  });
  testWidgets(
    'startup load failure can retry and asynchronous success opens home',
    (tester) async {
      var attempts = 0;
      final state = fakeState();
      await tester.pumpWidget(
        SprogApp(
          loadState: () async {
            await Future<void>.delayed(Duration.zero);
            if (++attempts == 1) throw const FormatException('missing_content');
            return state;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Indhold kunne ikke åbnes. Prøv igen'), findsOneWidget);
      await tester.tap(find.text('Indhold kunne ikke åbnes. Prøv igen'));
      await tester.pumpAndSettle();
      expect(find.text('Et lille skridt ad gangen'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'direct exercise route selects ID and ladder has a semantic sequence',
    (tester) async {
      final state = fakeState();
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(SprogApp(state: state));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold));
      Navigator.of(context).pushNamed('/lydtrappe/oevelse/ex-kvinde');
      await tester.pumpAndSettle();
      expect(find.text('kv_nde'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tapText(tester, 'Åbn lydtrappen');
      await tapText(tester, 'Vokaltrappen');
      expect(
        find.bySemanticsLabel(
          'Vokalrække i, derefter e, derefter æ, derefter a',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
      await state.audio.close();
      state.dispose();
    },
  );
}
