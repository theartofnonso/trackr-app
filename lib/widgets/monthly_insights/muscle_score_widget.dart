import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../controllers/exercise_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../screens/insights/sets_reps_volume_insights_screen.dart';
import '../../utils/exercise_logs_utils.dart';

class MuscleScoreWidget extends StatelessWidget {
  final List<RoutineLogDto> thisMonthLogs;
  final List<RoutineLogDto> lastMonthLogs;

  const MuscleScoreWidget({super.key, required this.thisMonthLogs, required this.lastMonthLogs});

  @override
  Widget build(BuildContext context) {
    final exerciseController = Provider.of<ExerciseController>(context, listen: false);

    final thisMonthScore = calculateMuscleScoreForLogs(routineLogs: thisMonthLogs, exercises: exerciseController.exercises);
    final lastMonthScore = calculateMuscleScoreForLogs(routineLogs: lastMonthLogs, exercises: exerciseController.exercises);

    final improved = thisMonthScore > lastMonthScore;

    return Container(
      decoration: BoxDecoration(
        color: sapphireDark80,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        onTap: () {
          context.push(SetsAndRepsVolumeInsightsScreen.routeName);
        },
        tileColor: sapphireDark80,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: Image.asset(
          'icons/dumbbells.png',
          fit: BoxFit.contain,
          height: 24, // Adjust the height as needed
        ),
        title: Text("Muscle Trend".toUpperCase(),
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text("Training frequency per muscle group",
            style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$thisMonthScore%",
                    style: GoogleFonts.ubuntu(
                        color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w900, fontSize: 20)),
                Text("$lastMonthScore%",
                    style: GoogleFonts.ubuntu(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12))
              ],
            ),
            const SizedBox(width: 4),
            FaIcon(
              improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
              color: improved ? vibrantGreen : Colors.deepOrange,
              size: 12,
            )
          ],
        ),
      ),
    );
  }
}
