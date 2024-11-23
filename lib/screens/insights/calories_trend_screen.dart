import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/date_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/chart/bar_chart.dart';

class CaloriesTrendScreen extends StatefulWidget {
  static const routeName = '/calories_trend_screen';

  const CaloriesTrendScreen({super.key});

  @override
  State<CaloriesTrendScreen> createState() => _CaloriesTrendScreenState();
}

class _CaloriesTrendScreenState extends State<CaloriesTrendScreen> {
  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange);

    final monthsInYear = generateMonthsInRange(range: dateRange);

    List<String> months = [];
    List<int> calories = [];
    for (final month in monthsInYear) {
      final startOfMonth = month.start;
      final endOfMonth = month.end;
      final logsForTheMonth = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfMonth, to: endOfMonth));
      final values = logsForTheMonth
          .map((log) => calculateCalories(duration: log.duration(), reps: routineUserController.weight(), activity: log.activityType))
          .sum;
      calories.add(values);
      months.add(startOfMonth.abbreviatedMonth());
    }

    final avgCalories = calories.average.round();

    final chartPoints =
        calories.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
        title: Text("Calories Trend".toUpperCase(),
            style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
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
                            style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
                            children: [
                              TextSpan(
                                text: " ",
                                style:
                                    GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              TextSpan(
                                text: "CALORIES".toUpperCase(),
                                style:
                                    GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "MONTHLY AVERAGE",
                          style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                calories.sum > 0 ? SizedBox(
                    height: 250,
                    child: CustomBarChart(
                      chartPoints: chartPoints,
                      periods: months,
                      unit: ChartUnit.number,
                      bottomTitlesInterval: 1,
                      showLeftTitles: true,
                      maxY: calories.max.toDouble(),
                      reservedSize: 35,
                    )) : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireDark, size: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
