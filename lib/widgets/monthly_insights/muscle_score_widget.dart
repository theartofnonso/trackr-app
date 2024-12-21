import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../screens/insights/sets_reps_volume_insights_screen.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/navigation_utils.dart';
import '../list_tile.dart';

class MuscleScoreWidget extends StatelessWidget {
  final List<RoutineLogDto> thisMonthLogs;
  final List<RoutineLogDto> lastMonthLogs;

  const MuscleScoreWidget({super.key, required this.thisMonthLogs, required this.lastMonthLogs});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final thisMonthScore = calculateMuscleScoreForLogs(routineLogs: thisMonthLogs);
    final lastMonthScore = calculateMuscleScoreForLogs(routineLogs: lastMonthLogs);

    final improved = thisMonthScore > lastMonthScore;

    return ThemeListTile(
      child: ListTile(
        onTap: () => _showSetsAndRepsVolumeInsightsScreen(context: context),
        leading: Image.asset(
          'icons/dumbbells.png',
          fit: BoxFit.contain,
          color: isDarkMode ? Colors.white : Colors.black,
          height: 24, // Adjust the height as needed
        ),
        title: Text("Muscle Trend".toUpperCase()),
        subtitle: Text("Frequency per muscle group"),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$thisMonthScore%",
                    style: Theme.of(context).textTheme.titleMedium),
                Text("$lastMonthScore%",
                    style: Theme.of(context).textTheme.titleSmall)
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

  void _showSetsAndRepsVolumeInsightsScreen({required BuildContext context}) {
    navigateWithSlideTransition(context: context, child: SetsAndRepsVolumeInsightsScreen());
  }
}
