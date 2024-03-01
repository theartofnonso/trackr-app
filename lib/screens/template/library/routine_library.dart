import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/screens/template/library/routine_library_template.dart';
import 'package:tracker_app/strings.dart';

import '../../../dtos/routine_template_dto.dart';
import '../../../enums/routine_template_library_workout_enum.dart';
import '../../../widgets/information_container_lite.dart';

class RoutineLibrary {
  final RoutineTemplateDto template;
  final String image;

  const RoutineLibrary({required this.template, required this.image});
}

class RoutineTemplateLibrary extends StatelessWidget {
  const RoutineTemplateLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = Provider.of<RoutineTemplateController>(context, listen: true)
        .defaultTemplates
        .map((template) => template.entries)
        .expand((element) => element)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        minimum: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          const InformationContainerLite(
            content: exploreWorkouts,
            color: Colors.transparent,
            padding: EdgeInsets.zero,
          ),
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
}

class _WorkoutListView extends StatelessWidget {
  final RoutineTemplateLibraryWorkoutEnum templateName;
  final List<RoutineLibrary> templateRoutines;

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
  final RoutineLibrary libraryTemplate;

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
          color: sapphireLight,
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
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark.withOpacity(0.4),
                  sapphireDark,
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

  void _navigateToRoutineTemplatePreview({required BuildContext context, required RoutineLibrary libraryTemplate}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RoutineLibraryTemplate(libraryTemplate: libraryTemplate)));
  }
}
