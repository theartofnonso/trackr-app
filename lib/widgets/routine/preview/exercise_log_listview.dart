import 'package:flutter/material.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';

import '../../../dtos/viewmodels/exercise_log_view_model.dart';
import 'exercise_log_widget.dart';

class ExerciseLogListView extends StatelessWidget {

  final List<ExerciseLogViewModel> exerciseLogs;
  final RoutinePreviewType previewType;

  const ExerciseLogListView({super.key, required this.exerciseLogs, required this.previewType});

  @override
  Widget build(BuildContext context) {
    final widgets = exerciseLogs.map((exerciseLog) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ExerciseLogWidget(
          exerciseLog: exerciseLog.exerciseLog,
          superSet: exerciseLog.superSet, previewType: previewType
        ),
      );
    }).toList();
    return Column(children: widgets);
  }
}