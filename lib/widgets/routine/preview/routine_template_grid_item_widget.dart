import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/dtos/routine_template_dto_extension.dart';

import '../../../colors.dart';
import '../../../dtos/appsync/routine_template_dto.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';

class RoutineTemplateGridItemWidget extends StatelessWidget {
  final RoutineTemplateDto template;
  final String scheduleSummary;

  const RoutineTemplateGridItemWidget({super.key, required this.template, required this.scheduleSummary});

  @override
  Widget build(BuildContext context) {
    final exercises = template.exerciseTemplates;
    final sets = template.exerciseTemplates.expand((exercise) => exercise.sets);
    return GestureDetector(
      onTap: () => navigateToRoutineTemplate(context: context, template: template),
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: sapphireDark80,
              borderRadius: BorderRadius.circular(10),
              gradient: template.isScheduledToday()
                  ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark80,
                  sapphireDark,
                ],
              )
                  : null,
              boxShadow: [
                BoxShadow(
                    color: sapphireDark.withOpacity(0.5), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3))
              ]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              template.name,
              style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            Text(
              "${exercises.length} ${pluralize(word: "Exercise", count: exercises.length)}",
              style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              "${sets.length} ${pluralize(word: "Set", count: sets.length)}",
              style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Divider(
                color: template.isScheduledToday() ? vibrantGreen.withOpacity(0.2) : sapphireLighter, endIndent: 10),
            const SizedBox(height: 8),
            Text(
              scheduleSummary,
              style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ])),
    );
  }
}