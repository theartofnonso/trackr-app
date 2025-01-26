import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/date_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../chart/line_chart_widget.dart';

class MuscleScoreChart extends StatelessWidget {
  const MuscleScoreChart({super.key});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange);

    final monthsInYear = generateMonthsInRange(range: dateRange);

    List<String> months = [];
    List<int> muscleScores = [];
    for (final month in monthsInYear) {
      final startOfMonth = month.start;
      final endOfMonth = month.end;
      final routineLogs =
          logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfMonth, to: endOfMonth)).toList();
      final muscleScore = calculateMuscleScoreForLogs(routineLogs: routineLogs);
      muscleScores.add(muscleScore);
      months.add(startOfMonth.abbreviatedMonth());
    }

    final muscleChartPoints = muscleScores.mapIndexed((index, value) => ChartPointDto(index, value)).toList();

    final averageMuscleScore = muscleScores.isNotEmpty ? (muscleScores.average).floorToDouble(): 0.0;

    final muscleCoverageFeedback = _muscleCoverageFeedback(averageMuscleScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "${averageMuscleScore.round()}%",
                style: Theme.of(context).textTheme.headlineSmall,
                children: [
                  TextSpan(
                    text: " ",
                  ),
                  TextSpan(
                    text: "score".toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              "Monthly AVERAGE".toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Text(
                muscleCoverageFeedback,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
          ],
        ),
        const SizedBox(height: 30),
        LineChartWidget(
          chartPoints: muscleChartPoints,
          periods: months,
          unit: ChartUnit.number,
          aspectRation: 2,
          leftReservedSize: 19,
          interval: 1,
        )
      ],
    );
  }

  String _muscleCoverageFeedback(double coverage) {
    final result = coverage / 100;
    if (result < 0.3) {
      return "Your muscle coverage is quite low. Try to include more muscle groups in your routine to prevent imbalances.";
    } else if (result < 0.6) {
      return "You're covering some muscle groups, but there’s room to broaden your workout to achieve better balance.";
    } else if (result < 0.8) {
      return "Good job! You're training most major muscle groups. Keep diversifying for more balanced strength.";
    } else {
      return "Excellent coverage! You’re hitting a wide range of muscle groups to prevent imbalances.";
    }
  }
}
