import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../dtos/appsync/routine_log_dto.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';

class RoutineLogWidget extends StatelessWidget {
  final RoutineLogDto log;
  final Color color;
  final String trailing;
  final bool isEditable;

  const RoutineLogWidget(
      {super.key, required this.log, required this.color, required this.trailing, this.isEditable = true});

  @override
  Widget build(BuildContext context) {
    final completedExerciseLogsAndSets = loggedExercises(exerciseLogs: log.exerciseLogs);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric( horizontal: 16),
        onTap: () => navigateToRoutineLogPreview(context: context, log: log, isEditable: isEditable),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: vibrantGreen.withOpacity(0.1), // Background color
            borderRadius: BorderRadius.circular(5), // Rounded corners
          ),
          child: Image.asset(
            'icons/dumbbells.png',
            fit: BoxFit.contain,
            height: 24,
            color: vibrantGreen, // Adjust the height as needed
          ),
        ),
        title: Text(log.name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(
            "${completedExerciseLogsAndSets.length} ${pluralize(word: "exercise", count: completedExerciseLogsAndSets.length)}",
            style: GoogleFonts.ubuntu(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: Text(trailing,
            style: GoogleFonts.ubuntu(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}
