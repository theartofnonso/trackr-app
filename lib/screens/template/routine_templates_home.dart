import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/template/library/routine_template_library.dart';
import 'package:tracker_app/screens/template/routine_templates_screen.dart';

import '../../colors.dart';
import '../../controllers/exercise_controller.dart';
import '../../controllers/routine_template_controller.dart';

class RoutineTemplatesHome extends StatefulWidget {

  static const routeName = '/routine-templates-screen';

  const RoutineTemplatesHome({super.key});

  @override
  State<RoutineTemplatesHome> createState() => _RoutineTemplatesHomeState();
}

class _RoutineTemplatesHomeState extends State<RoutineTemplatesHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: sapphireDark80,
            toolbarHeight: 0,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(child: Text("My Workouts", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(child: Text("Explore", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          body: Container(
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
            child: const SafeArea(
              child: TabBarView(
                children: [
                  RoutineTemplatesScreen(),
                  RoutineTemplateLibrary(),
                ],
              ),
            ),
          ),
        ));
  }

  void loadTemplates() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exercises = Provider.of<ExerciseController>(context, listen: false).exercises;
      Provider.of<RoutineTemplateController>(context, listen: false).loadTemplatesFromAssets(exercises: exercises);
    });
  }

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }
}
