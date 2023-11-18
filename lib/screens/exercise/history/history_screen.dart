import 'package:flutter/material.dart';

import '../../../models/RoutineLog.dart';
import '../../../widgets/empty_states/screen_empty_state.dart';
import '../../../widgets/exercise_history/routine_log_widget.dart';

class HistoryScreen extends StatelessWidget {
  final List<RoutineLog> logs;

  const HistoryScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logs.isNotEmpty
              ? Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => RoutineLogWidget(routineLog: logs[index]),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                itemCount: logs.length),
          )
              : const Center(child: ScreenEmptyState(message: "You have no logs")),
        ],
      ),
    );
  }
}