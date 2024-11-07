import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import 'completed_milestones_screen.dart';
import 'pending_milestones_screen.dart';

class MilestonesHomeScreen extends StatelessWidget {
  const MilestonesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    List<RoutineLogDto> routineLogsForTheYear =
    routineLogController.whereLogsIsSameYear(dateTime: DateTime.now().withoutTime());

    routineLogsForTheYear.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final pendingMilestones = routineLogController.pendingMilestones;

    final completedMilestones = routineLogController.completedMilestones;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: sapphireDark80,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                    child: Text("Milestones",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(
                    child: Text("Completed",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark80,
                  sapphireDark,
                ],
              ),
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
