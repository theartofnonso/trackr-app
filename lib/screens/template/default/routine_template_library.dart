import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/screens/template/default/routine_template_library_screen.dart';
import 'package:tracker_app/strings.dart';

import '../../../controllers/exercise_controller.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../enums/routine_template_library_workout_enum.dart';

class RoutineLibraryTemplate {
  final RoutineTemplateDto template;
  final String image;

  const RoutineLibraryTemplate({required this.template, required this.image});
}

class RoutineTemplateLibrary extends StatefulWidget {
  const RoutineTemplateLibrary({super.key});

  @override
  State<RoutineTemplateLibrary> createState() => _RoutineTemplateLibraryState();
}

class _RoutineTemplateLibraryState extends State<RoutineTemplateLibrary> {
  @override
  Widget build(BuildContext context) {
    final templates = Provider.of<RoutineTemplateController>(context, listen: true)
        .defaultTemplates
        .map((template) => template.entries)
        .expand((element) => element)
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Text(exploreWorkouts,
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 250),
                itemBuilder: (BuildContext context, int index) =>
                    _WorkoutListView(templateName: templates[index].key, templateRoutines: templates[index].value),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
                itemCount: templates.length),
          )
        ]),
      ),
    );
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

class _WorkoutListView extends StatelessWidget {
  final RoutineTemplateLibraryWorkoutEnum templateName;
  final List<RoutineLibraryTemplate> templateRoutines;

  const _WorkoutListView({required this.templateName, required this.templateRoutines});

  @override
  Widget build(BuildContext context) {

    final children = templateRoutines.map((libraryTemplate) {

      return _WorkoutCard(libraryTemplate: libraryTemplate);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(templateName.name.toUpperCase(),
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: children)),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final RoutineLibraryTemplate libraryTemplate;

  const _WorkoutCard({required this.libraryTemplate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToRoutineTemplatePreview(context: context, libraryTemplate: libraryTemplate),
      child: Container(
        width: 150,
        height: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: tealBlueLight,
        ),
        child: Stack(children: [
          Positioned.fill(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.asset(
              'images/${libraryTemplate.image}',
              fit: BoxFit.cover,
            ),
          )),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tealBlueDark.withOpacity(0.4),
                  tealBlueDark,
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(libraryTemplate.template.name.toUpperCase(),
                  style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          )
        ]),
      ),
    );
  }

  void _navigateToRoutineTemplatePreview({required BuildContext context, required RoutineLibraryTemplate libraryTemplate}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RoutineTemplateLibraryScreen(libraryTemplate: libraryTemplate)));
  }
}
