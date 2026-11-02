import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/lesson_repository.dart';
import '../../progress/progress_repository.dart';

class ExerciseController extends ChangeNotifier {
  ExerciseController(this.exercises, this.progress, {this.onPosition});
  final Future<void> Function(Exercise? exercise, bool? correct)? onPosition;
  Future<void> visit() =>
      onPosition?.call(finished ? null : current, correct) ?? Future.value();
  final List<Exercise> exercises;
  final ProgressRepository progress;
  int index = 0;
  bool? correct;
  bool finished = false;
  Exercise get current => exercises[index];
  Future<void> submit(String answer, {bool allowFreeText = false}) async {
    if (correct != null ||
        finished ||
        answer.isEmpty ||
        (!allowFreeText && !current.options.contains(answer))) {
      return;
    }
    correct = current.accepts(answer);
    final save = progress.record(current.id, correct!);
    notifyListeners();
    await Future.wait([save, visit()]);
  }

  void retry() {
    if (correct == false) {
      correct = null;
      unawaited(visit());
      notifyListeners();
    }
  }

  void next() {
    if (correct != true) return;
    if (index + 1 >= exercises.length) {
      finished = true;
    } else {
      index++;
      correct = null;
    }
    unawaited(visit());
    notifyListeners();
  }

  void restart({bool remember = true}) {
    index = 0;
    correct = null;
    finished = false;
    if (remember) unawaited(visit());
    notifyListeners();
  }
}
