import 'package:flutter/material.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';

import '../../../dtos/viewmodels/exercise_log_view_model.dart';
import 'exercise_log_widget.dart';

class ExerciseLogListView extends StatelessWidget {

  final List<ExerciseLogViewModel> exerciseLogs;

  const ExerciseLogListView({super.key, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {
    final widgets = exerciseLogs.map((exerciseLog) {
      return ExerciseLogWidget(
        padding: const EdgeInsets.only(bottom: 8),
        exerciseLog: exerciseLog.exerciseLog,
        superSet: exerciseLog.superSet,
      );
    }).toList();
    return Column(children: widgets);
  }
}