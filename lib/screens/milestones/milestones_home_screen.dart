import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../utils/general_utils.dart';
import 'completed_milestones_screen.dart';
import 'pending_milestones_screen.dart';

class MilestonesHomeScreen extends StatelessWidget {
  const MilestonesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final pendingMilestones = routineLogController.pendingMilestones;

    final completedMilestones = routineLogController.completedMilestones;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(child: Text("Active".toUpperCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                Tab(child: Text("Completed".toUpperCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  Expanded(
                    child: TabBarView(
                      children: [
                        PendingMilestonesScreen(milestones: pendingMilestones),
                        CompletedMilestonesScreen(milestones: completedMilestones)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
