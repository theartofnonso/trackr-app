import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/screens/templates/programs/routine_programs_home.dart';
import 'package:tracker_app/screens/templates/routine_templates_screen.dart';

import '../../colors.dart';

class TemplatesAndProgramsHome extends StatelessWidget {
  const TemplatesAndProgramsHome({super.key});

  @override
  Widget build(BuildContext context) {

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
                    child: Text("Workouts",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(
                    child: Text("Plans",
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
                        RoutineTemplatesScreen(),
                        RoutineProgramsHome()
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
