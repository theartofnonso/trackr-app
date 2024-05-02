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
                    _WorkoutGridView(templateName: templates[index].key, templateRoutines: templates[index].value),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
                itemCount: templates.length),
          )
        ]),
      ),
    );
  }
}

class _WorkoutGridView extends StatelessWidget {
  final RoutineTemplateLibraryWorkoutEnum templateName;
  final List<RoutineLibrary> templateRoutines;

  const _WorkoutGridView({required this.templateName, required this.templateRoutines});

  @override
  Widget build(BuildContext context) {

    final children = templateRoutines.map((libraryTemplate) {

      return _RoutineWidget(libraryTemplate: libraryTemplate);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(templateName.name.toUpperCase(),
            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            children: children)],
    );
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineLibrary libraryTemplate;

  const _RoutineWidget({required this.libraryTemplate});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(splashColor: sapphireLight),
        child: GestureDetector(
          onTap: () => _navigateToRoutineTemplatePreview(context: context, libraryTemplate: libraryTemplate),
          child: Container(
              decoration: BoxDecoration(
                  color: sapphireDark80,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)]),
              child: Stack(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(
                        backgroundColor: vibrantGreen,
                        foregroundColor: sapphireDark,
                        child: Text("${libraryTemplate.template.exerciseTemplates.length}",
                            style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w700)),
                      ),
                      const Spacer(),
                      Text(
                        libraryTemplate.template.name,
                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ]),
                  )
                ],
              )),
        ));
  }

  void _navigateToRoutineTemplatePreview({required BuildContext context, required RoutineLibrary libraryTemplate}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RoutineLibraryTemplate(libraryTemplate: libraryTemplate)));
  }
}
