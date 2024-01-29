import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/repositories/amplify_template_repository.dart';
import 'package:tracker_app/strings.dart';

import '../../controllers/exercise_controller.dart';
import '../../dtos/routine_template_dto.dart';
import '../../utils/navigation_utils.dart';

class RoutineTemplateLibrary extends StatefulWidget {
  const RoutineTemplateLibrary({super.key});

  @override
  State<RoutineTemplateLibrary> createState() => _RoutineTemplateLibraryState();
}

class _RoutineTemplateLibraryState extends State<RoutineTemplateLibrary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Text(exploreWorkouts,
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          const _WorkoutListView(templates: [])
        ]),
      ),
    );
  }

  void loadTemplates() async {
    final exercises = Provider.of<ExerciseController>(context).exercises;
    Provider.of<RoutineTemplateController>(context).fetchDefaultWorkouts(exercises: exercises);
  }

  @override
  void initState() {
    super.initState();

    loadTemplates();

  }
}

class _WorkoutListView extends StatelessWidget {
  final List<RoutineTemplateDto> templates;
  const _WorkoutListView({required this.templates});

  @override
  Widget build(BuildContext context) {

    final children = templates.map((template) => _WorkoutCard(template: template)).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Text("Push Pull Legs",
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: children),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final RoutineTemplateDto template;

  const _WorkoutCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: tealBlueLight,
        ),
        child: Stack(children: [
          Positioned.fill(child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.asset(
              'assets/img.jpg',
              fit: BoxFit.cover,
            ),
          )),
          Opacity(
            opacity: 0.9,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tealBlueDark,
                    tealBlueLight,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("PUSH",
                  style: GoogleFonts.montserrat(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          )
        ]),
      ),
    );
  }
}
