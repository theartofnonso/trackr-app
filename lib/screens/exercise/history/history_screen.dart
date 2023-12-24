import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/models/Exercise.dart';

import '../../../providers/routine_log_provider.dart';
import '../../../widgets/empty_states/list_view_empty_state.dart';
import '../../../widgets/exercise_history/routine_log_widget.dart';

class HistoryScreen extends StatelessWidget {
  final Exercise exercise;

  const HistoryScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    List<ExerciseLogDto> pastLogs = Provider.of<RoutineLogProvider>(context, listen: false).exerciseLogsById[exercise.id] ?? [];
    pastLogs = pastLogs.reversed.toList();
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