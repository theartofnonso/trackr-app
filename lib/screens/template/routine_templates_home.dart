import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/screens/template/routine_template_library.dart';
import 'package:tracker_app/screens/template/routine_templates_screen.dart';

class RoutineTemplatesHome extends StatelessWidget {
  const RoutineTemplatesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(child: Text("My Workouts", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(child: Text("Explore", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                RoutineTemplatesScreen(),
                RoutineTemplateLibrary(),
              ],
            ),
          ),
        ));
  }
}
