import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../../widgets/empty_states/list_view_empty_state.dart';
import '../../../widgets/exercise_history/routine_log_widget.dart';

class HistoryScreen extends StatelessWidget {
  final List<ExerciseLogDto> exerciseLogs;

  const HistoryScreen({super.key, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {
    final reversed = exerciseLogs.reversed.toList();
    return Padding(
      padding: const EdgeInsets.only(top: 2, right: 10.0, bottom: 10, left: 10),
      child: Column(
        children: [
          exerciseLogs.isNotEmpty
              ? Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => RoutineLogWidget(exerciseLog: reversed[index]),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                itemCount: exerciseLogs.length),
          )
              : const ListViewEmptyState(),
        ],
      ),
    );
  }
}