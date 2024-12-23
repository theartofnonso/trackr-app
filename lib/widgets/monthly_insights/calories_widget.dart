import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/insights/calories_trend_screen.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/abstract_class/log_class.dart';
import '../../utils/navigation_utils.dart';
import '../list_tile.dart';

class CaloriesWidget extends StatelessWidget {
  final List<Log> thisMonthLogs;
  final List<Log> lastMonthLogs;

  const CaloriesWidget({super.key, required this.thisMonthLogs, required this.lastMonthLogs});

  @override
  Widget build(BuildContext context) {
    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final thisMonthCount = thisMonthLogs
        .map((log) => calculateCalories(
            duration: log.duration(), bodyWeight: routineUserController.weight(), activity: log.activityType))
        .sum;
    final lastMonthCount = lastMonthLogs
        .map((log) => calculateCalories(
            duration: log.duration(), bodyWeight: routineUserController.weight(), activity: log.activityType))
        .sum;

    final improved = thisMonthCount > lastMonthCount;

    final difference = improved ? thisMonthCount - lastMonthCount : lastMonthCount - lastMonthCount;

    final differenceSummary = improved ? "Improved by $difference kcal" : "Reduced by $difference kcal";

    return ThemeListTile(
      child: ListTile(
        onTap: () => _showCaloriesScreen(context: context, differenceSummary: differenceSummary, improved: improved),
        leading: const FaIcon(FontAwesomeIcons.fire),
        title: Text("Calories".toUpperCase()),
        subtitle: Text("Amount of energy expenditure"),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$thisMonthCount", style: Theme.of(context).textTheme.titleMedium),
                Text("$lastMonthCount", style: Theme.of(context).textTheme.titleSmall)
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

  void _showCaloriesScreen({required BuildContext context, required String differenceSummary, required bool improved}) {
    navigateWithSlideTransition(
        context: context, child: CaloriesTrendScreen(differenceSummary: differenceSummary, improved: improved));
  }
}
