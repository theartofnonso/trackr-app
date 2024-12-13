import 'package:flutter/material.dart';

import '../../../dtos/viewmodels/exercise_log_view_model.dart';
import 'exercise_log_widget.dart';

class ExerciseLogListView extends StatelessWidget {

  final List<ExerciseLogViewModel> exerciseLogs;

  const ExerciseLogListView({super.key, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final exerciseLog = exerciseLogs[index];
          return ExerciseLogWidget(
            exerciseLog: exerciseLog.exerciseLog,
            superSet: exerciseLog.superSet,
          );
        }, separatorBuilder: (context, index) {
          return SizedBox(height: 22);
    }, itemCount: exerciseLogs.length);
  }
}