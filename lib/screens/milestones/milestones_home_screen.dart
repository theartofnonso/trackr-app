import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../repositories/milestones_repository.dart';
import 'completed_milestones_screen.dart';
import 'uncompleted_milestones_screen.dart';

class MilestonesHomeScreen extends StatelessWidget {
  const MilestonesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final milestones = MilestonesRepository().loadMilestones();

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
                        UncompletedMilestonesScreen(milestones: milestones),
                        CompletedMilestonesScreen(milestones: milestones)
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
