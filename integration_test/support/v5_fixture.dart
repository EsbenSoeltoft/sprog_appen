import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprog_appen/features/lydtrappen/data/lesson_repository.dart';
import 'package:sprog_appen/features/stavelser_endelser/data/syllable_repository.dart';
import 'package:sprog_appen/features/udsagnsord/verb_repository.dart';
import 'package:sprog_appen/features/progress/progress_repository.dart';

const backupKey = '_integration_v5_backup';
Future<Set<String>> knownIds() async {
  final v1 = await LessonRepository().load(),
      v2 = await SyllableRepository().load(),
      v3 = await WordStructureRepository().load(),
      v4 = await VerbRepository().load();
  return {
    ...v1.exercises.map((e) => e.id),
    ...v2.exerciseIds,
    ...v3.exerciseIds,
    ...v4.practice.exerciseIds,
  };
}

Future<void> tapV5(WidgetTester tester, String label) async {
  final text = find.text(label);
  if (text.evaluate().isNotEmpty) {
    await tester.ensureVisible(text);
    await tester.pumpAndSettle();
  }
  await tester.scrollUntilVisible(
    text.hitTestable(),
    150,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 100,
  );
  await tester.tap(text.hitTestable());
  await tester.pumpAndSettle();
}

Future<void> backupProgress() async {
  final prefs = SharedPreferencesAsync();
  if (await prefs.getString(backupKey) == null) {
    await prefs.setString(
      backupKey,
      jsonEncode({'raw': await prefs.getString('progress_v1')}),
    );
  }
}

Future<void> restoreProgress() async {
  final prefs = SharedPreferencesAsync();
  final backup = await prefs.getString(backupKey);
  if (backup == null) return;
  final raw = (jsonDecode(backup) as Map<String, dynamic>)['raw'];
  if (raw == null) {
    await prefs.remove('progress_v1');
  } else {
    await prefs.setString('progress_v1', raw as String);
  }
  await prefs.remove(backupKey);
}

Future<ProgressRepository> readProgress() async {
  final p = ProgressRepository(PreferencesProgressStore());
  await p.load(await knownIds());
  return p;
}
