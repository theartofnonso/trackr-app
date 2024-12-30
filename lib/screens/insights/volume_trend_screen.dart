import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/exercise_type_enums.dart';
import '../../utils/date_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/chart/line_chart_widget.dart';
import '../../widgets/information_containers/information_container.dart';

class VolumeTrendScreen extends StatelessWidget {
  static const routeName = '/volume_trend_screen';

  const VolumeTrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController
        .whereLogsIsWithinRange(range: dateRange)
        .map((log) => routineWithLoggedExercises(log: log))
        .toList();

    final monthsInYear = generateMonthsInRange(range: dateRange);

    List<String> months = [];
    List<double> volumes = [];
    for (final month in monthsInYear) {
      final startOfMonth = month.start;
      final endOfMonth = month.end;
      final logsForTheMonth = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfMonth, to: endOfMonth));
      final values = logsForTheMonth
          .expand((log) => log.exerciseLogs)
          .expand((exerciseLog) => exerciseLog.sets)
          .map((set) {
            return switch (set.type) {
              ExerciseType.weights => (set as WeightAndRepsSetDto).volume(),
              ExerciseType.bodyWeight => 0,
              ExerciseType.duration => 0,
            };
          })
          .sum
          .toDouble();
      volumes.add(values);
      months.add(startOfMonth.abbreviatedMonth());
    }

    final avgVolume = volumes.isNotEmpty ? volumes.average : 0.0;

    final chartPoints =
        volumes.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final currentAndPreviousMonthVolume =
        _calculateCurrentAndPreviousMonthVolume(logs: logs, monthsInYear: monthsInYear);

    final previousMonthVolume = currentAndPreviousMonthVolume.$1;
    final currentMonthVolume = currentAndPreviousMonthVolume.$2;

    final improved = currentMonthVolume > previousMonthVolume;

    final difference = improved ? currentMonthVolume - previousMonthVolume : previousMonthVolume - currentMonthVolume;

    final differenceSummary = _generateDifferenceSummary(improved: improved, difference: difference);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
          onPressed: context.pop,
        ),
        title: Text("Volume Trend".toUpperCase()),
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
                            text: volumeInKOrM(avgVolume),
                            style: Theme.of(context).textTheme.headlineMedium,
                            children: [
                              TextSpan(
                                text: " ",
                              ),
                              TextSpan(
                                text: weightLabel().toUpperCase(),
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
                              getImprovementIcon(improved: improved, difference: difference),
                              color: getImprovementColor(improved: improved, difference: difference),
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            OpacityButtonWidget(
                              label: differenceSummary,
                              buttonColor: getImprovementColor(improved: improved, difference: difference),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                volumes.sum > 0
                    ? LineChartWidget(
                        chartPoints: chartPoints,
                        periods: months,
                        unit: ChartUnit.weight,
                        aspectRation: 2,
                        reservedSize: 30,
                        interval: 1,
                        colors: [])
                    : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireDark, size: 120)),
                const SizedBox(height: 16),
                InformationContainer(
                  leadingIcon: FaIcon(FontAwesomeIcons.weightHanging),
                  title: "Training Volume",
                  color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
                  description:
                      "Volume is the total amount of work done (It is a measure of intensity), often calculated as sets × reps × weight. Higher volume increases muscle size (hypertrophy).",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  (double, double) _calculateCurrentAndPreviousMonthVolume(
      {required List<RoutineLogDto> logs, required List<DateTimeRange> monthsInYear}) {
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

    // 4. Calculate total volume for each month
    final currentMonthVolume =
        currentMonthLogs.map((log) => log.volume).sum; // .sum is from collection.dart or your own utility

    final previousMonthVolume = previousMonthLogs.map((log) => log.volume).sum;

    return (previousMonthVolume, currentMonthVolume);
  }

  String _generateDifferenceSummary({required bool improved, required double difference}) {
    if (difference <= 0) {
      return "0 change in past month";
    } else {
      if (improved) {
        return "${volumeInKOrM(difference)} ${weightLabel()} up this month";
      } else {
        return "${volumeInKOrM(difference)} ${weightLabel()} down this month";
      }
    }
  }
}
