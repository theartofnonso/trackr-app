import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';

import '../../../widgets/exercise_history/exercise_history_log_widget.dart';
import '../../../widgets/empty_states/no_list_empty_state.dart';

class HistoryScreen extends StatelessWidget {
  final List<ExerciseLogDTO> exerciseLogs;

  const HistoryScreen({super.key, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {
    final reversed = exerciseLogs.reversed.toList();
    return Padding(
      padding: EdgeInsets.only(top: exerciseLogs.isNotEmpty ? 0 : 20, right: 10.0, bottom: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          exerciseLogs.isNotEmpty
              ? Expanded(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) =>
                          ExerciseHistoryLogWidget(exerciseLog: reversed[index]),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                      itemCount: exerciseLogs.length),
                )
              : Expanded(
                child: const NoListEmptyState(
                    icon: FaIcon(
                      FontAwesomeIcons.solidLightbulb,
                      color: Colors.white12,
                      size: 48,
                    ),
                    message: "It might feel quiet now, but your history will soon appear here.",
                  ),
              ),
        ],
      ),
    );
  }
}
