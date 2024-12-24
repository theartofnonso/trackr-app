import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/information_containers/information_container.dart';

import '../../colors.dart';
import '../../controllers/activity_log_controller.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/abstract_class/log_class.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/date_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/chart/bar_chart.dart';

class CaloriesTrendScreen extends StatelessWidget {
  static const routeName = '/calories_trend_screen';

  const CaloriesTrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final activityLogController = Provider.of<ActivityLogController>(context, listen: false);

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final routineLogs = routineLogController.whereLogsIsWithinRange(range: dateRange);

    final activityLogs = activityLogController.whereLogsIsWithinRange(range: dateRange);

    final logs = [...routineLogs, ...activityLogs];

    final monthsInYear = generateMonthsInRange(range: dateRange);

    List<String> months = [];
    List<int> calories = [];
    for (final month in monthsInYear) {
      final startOfMonth = month.start;
      final endOfMonth = month.end;
      final logsForTheMonth = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfMonth, to: endOfMonth));
      final values = logsForTheMonth
          .map((log) => calculateCalories(
              duration: log.duration(), bodyWeight: routineUserController.weight(), activity: log.activityType))
          .sum;
      calories.add(values);
      months.add(startOfMonth.abbreviatedMonth());
    }

    final avgCalories = calories.average.round();

    final chartPoints =
        calories.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final currentAndPreviousMonthCalories = _calculateCurrentAndPreviousMonthCalories(
        weight: routineUserController.weight(), logs: logs, monthsInYear: monthsInYear);

    final previousMonthCalories = currentAndPreviousMonthCalories.$1;
    final currentMonthCalories = currentAndPreviousMonthCalories.$2;

    final improved = currentMonthCalories > previousMonthCalories;

    final difference =
        improved ? currentMonthCalories - previousMonthCalories : previousMonthCalories - currentMonthCalories;

    final differenceSummary = improved ? "Improved by $difference kcal" : "Reduced by $difference kcal";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
          onPressed: context.pop,
        ),
        title: Text("Calories Trend".toUpperCase()),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "$avgCalories",
                            style: Theme.of(context).textTheme.headlineMedium,
                            children: [
                              TextSpan(
                                text: " ",
                              ),
                              TextSpan(
                                text: "kcal".toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "MONTHLY AVERAGE".toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FaIcon(
                              improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                              color: improved ? vibrantGreen : Colors.deepOrange,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            OpacityButtonWidget(
                              label: differenceSummary,
                              buttonColor: improved ? vibrantGreen : Colors.deepOrange,
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                calories.sum > 0
                    ? SizedBox(
                        height: 250,
                        child: CustomBarChart(
                          chartPoints: chartPoints,
                          periods: months,
                          unit: ChartUnit.number,
                          bottomTitlesInterval: 1,
                          showLeftTitles: true,
                          maxY: calories.max.toDouble(),
                          reservedSize: 35,
                        ))
                    : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireDark, size: 120)),
                const SizedBox(height: 14),
                InformationContainer(
                  leadingIcon: FaIcon(FontAwesomeIcons.fire),
                  title: "What are calories",
                  color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
                  description:
                      "Calories burned refer to the amount of energy your body uses during an activity. This energy is measured in calories and comes from breaking down carbohydrates, fats, and proteins in your body.",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  (int, int) _calculateCurrentAndPreviousMonthCalories(
      {required double weight, required List<Log> logs, required List<DateTimeRange> monthsInYear}) {
    // 1. Ensure monthsInYear has at least two items (current & previous)
    if (monthsInYear.length < 2) {
      // Handle the edge case (e.g., not enough months to compare)
      return (0, 0);
    }

    // 2. Identify the current month and the previous month
    final currentMonthRange = monthsInYear.last;
    final previousMonthRange = monthsInYear[monthsInYear.length - 2];

    // 3. Fetch logs for each month
    final currentMonthLogs = logs.where((log) {
      return log.createdAt.isBetweenInclusive(
        from: currentMonthRange.start,
        to: currentMonthRange.end,
      );
    });

    final previousMonthLogs = logs.where((log) {
      return log.createdAt.isBetweenInclusive(
        from: previousMonthRange.start,
        to: previousMonthRange.end,
      );
    });

    // 4. Calculate total calories for each month
    final currentMonthCalories = currentMonthLogs
        .map((log) => calculateCalories(duration: log.duration(), bodyWeight: weight, activity: log.activityType))
        .sum; // .sum is from collection.dart or your own utility

    final previousMonthCalories = previousMonthLogs
        .map((log) => calculateCalories(duration: log.duration(), bodyWeight: weight, activity: log.activityType))
        .sum;

    return (previousMonthCalories, currentMonthCalories);
  }
}
