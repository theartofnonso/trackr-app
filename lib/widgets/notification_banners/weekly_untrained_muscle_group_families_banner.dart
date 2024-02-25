import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../utils/string_utils.dart';
import '../information_container.dart';

class WeeklyUntrainedMuscleGroupFamiliesBanner extends StatelessWidget {
  final void Function() onDismiss;

  const WeeklyUntrainedMuscleGroupFamiliesBanner({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RoutineLogController>(context, listen: false);

    final untrainedMuscleGroups = controller.untrainedMuscleGroupFamilies;

    final unTrainedMuscleGroupsNames = joinWithAnd(items: untrainedMuscleGroups.map((muscle) => muscle.name).toList());

    return InformationContainer(
        leadingIcon: const FaIcon(FontAwesomeIcons.lightbulb, color: Colors.white, size: 16),
        trailingIcon: GestureDetector(
            onTap: onDismiss, child: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: vibrantGreen, size: 22)),
        title: "This week's goal",
        richDescription: RichText(
            text: TextSpan(
                text: "You didn't train",
                style: GoogleFonts.montserrat(
                    color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
                children: [
              const TextSpan(text: " "),
              TextSpan(
                  text: unTrainedMuscleGroupsNames,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const TextSpan(text: " "),
              TextSpan(
                  text: "last week.",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const TextSpan(text: " "),
              TextSpan(
                  text: "Try to include them in your training this week.",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
            ])),
        color: sapphireDark60);
  }
}
