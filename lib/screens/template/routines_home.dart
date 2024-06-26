import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/template/library/routine_library.dart';
import 'package:tracker_app/screens/template/templates/routine_templates.dart';

import '../../colors.dart';
import '../../controllers/exercise_controller.dart';
import '../../controllers/routine_template_controller.dart';

class RoutinesHome extends StatefulWidget {

  static const routeName = '/routine-templates-screen';

  const RoutinesHome({super.key});

  @override
  State<RoutinesHome> createState() => _RoutinesHomeState();
}

class _RoutinesHomeState extends State<RoutinesHome> {
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
            child: const SafeArea(
              child: TabBarView(
                children: [
                  RoutineTemplates(),
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
