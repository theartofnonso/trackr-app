import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/template/library/routine_template_library.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../../../app_constants.dart';
import '../../../controllers/routine_template_controller.dart';

class RoutineTemplateLibraryScreen extends StatelessWidget {
  final RoutineLibraryTemplate libraryTemplate;

  const RoutineTemplateLibraryScreen({super.key, required this.libraryTemplate});

  @override
  Widget build(BuildContext context) {
    final exercises = libraryTemplate.template.exercises
        .map((exercise) => ListTile(
              contentPadding: const EdgeInsets.only(left: 10),
              title: Text(exercise.exercise.name, style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white)),
            ))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          heroTag: UniqueKey,
          onPressed: () => _saveTemplate(context: context),
          backgroundColor: tealBlueLighter,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: const FaIcon(FontAwesomeIcons.download, size: 20)),
      backgroundColor: tealBlueDark,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Stack(children: [
            Positioned.fill(
                child: Image.asset(
              'images/${libraryTemplate.image}',
              fit: BoxFit.cover,
            )),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tealBlueDark.withOpacity(0.4),
                    tealBlueDark.withOpacity(0.8),
                    tealBlueDark,
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(libraryTemplate.template.name.toUpperCase(),
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(libraryTemplate.template.notes,
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Curated by",
                            style:
                                GoogleFonts.montserrat(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 3),
                        Image.asset(
                          'images/trackr.png',
                          fit: BoxFit.contain,
                          height: 9, //
                          color: vibrantGreen, // Adjust the height as needed
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ]),
              ),
            )
          ]),
        ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(children: [
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 250),
                      itemBuilder: (BuildContext context, int index) => exercises[index],
                      separatorBuilder: (BuildContext context, int index) => const Divider(
                            thickness: 1.0,
                            color: tealBlueLight,
                          ),
                      itemCount: exercises.length),
                )
              ])),
        )
      ]),
    );
  }

  void _saveTemplate({required BuildContext context}) async {
    final templateController = Provider.of<RoutineTemplateController>(context, listen: false);
    final template = await templateController.saveTemplate(templateDto: libraryTemplate.template);
    if (template != null) {
      if (context.mounted) {
        navigateToRoutineTemplatePreview(context: context, template: template);
      }
    }
  }
}
