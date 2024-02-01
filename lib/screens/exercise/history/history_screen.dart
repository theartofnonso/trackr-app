import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import '../../../dtos/exercise_dto.dart';
import '../../../controllers/routine_log_controller.dart';
import '../../../widgets/empty_states/list_view_empty_state.dart';
import '../../../widgets/exercise_history/routine_log_widget.dart';

class HistoryScreen extends StatelessWidget {
  final ExerciseDto exercise;

  const HistoryScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    List<ExerciseLogDto> pastLogs = Provider.of<RoutineLogController>(context, listen: false).exerciseLogsById[exercise.id] ?? [];
    pastLogs = exerciseLogsWithCheckedSets(exerciseLogs: pastLogs.reversed.toList());
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          pastLogs.isNotEmpty
              ? Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => RoutineLogWidget(exerciseLog: pastLogs[index]),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                itemCount: pastLogs.length),
          )
              : const ListViewEmptyState(),
        ],
      ),
    );
  }
}