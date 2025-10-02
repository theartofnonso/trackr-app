import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/db/routine_plan_dto.dart';

import '../../../colors.dart';
import '../../../dtos/db/routine_template_dto.dart';
import '../../../utils/string_utils.dart';
import '../../icons/custom_icon.dart';

class RoutineTemplateGridItemWidget extends StatelessWidget {
  final RoutineTemplateDto template;
  final RoutinePlanDto? plan;
  final void Function()? onTap;

  const RoutineTemplateGridItemWidget(
      {super.key, required this.template, this.onTap, this.plan});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exercises = template.exerciseTemplates;

    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDarkMode ? darkSurfaceContainer : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(radiusMD)),
          child: Column(
              spacing: 14,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan != null)
                  Text("In ${plan?.name}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black,
                          height: 1.5,
                          fontWeight: FontWeight.w400)),
                const Spacer(),
                Text(
                  template.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: plan != null ? 1 : 3,
                ),
                Wrap(
                  children: [
                    CustomIcon(
                      FontAwesomeIcons.personWalking,
                      color: vibrantGreen,
                      width: 20,
                      height: 20,
                      iconSize: 10.5,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      "${exercises.length} ${pluralize(word: "Exercise", count: exercises.length)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ])),
    );
  }
}
