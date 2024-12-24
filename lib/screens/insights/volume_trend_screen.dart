import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/exercise_type_enums.dart';
import '../../utils/date_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/chart/bar_chart.dart';
import '../../widgets/information_containers/information_container.dart';

class VolumeTrendScreen extends StatelessWidget {
  static const routeName = '/volume_trend_screen';

  const VolumeTrendScreen({super.key, required this.differenceSummary, required this.improved});

  final String differenceSummary;
  final bool improved;

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final dateRange = theLastYearDateTimeRange();

    final logs = routineLogController.whereLogsIsWithinRange(range: dateRange);

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

    final avgVolume = volumes.average;

    final chartPoints =
        volumes.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

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
                              improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                              color: improved ? vibrantGreen : Colors.deepOrange,
                              size: 12,
                            ),
                          const SizedBox(width: 6),
                          OpacityButtonWidget(label: differenceSummary,buttonColor: improved ? vibrantGreen : Colors.deepOrange, )
                        ],)
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                volumes.sum > 0
                    ? SizedBox(
                        height: 250,
                        child: CustomBarChart(
                          chartPoints: chartPoints,
                          periods: months,
                          unit: ChartUnit.weight,
                          bottomTitlesInterval: 1,
                          showLeftTitles: true,
                          maxY: volumes.max.toDouble(),
                          reservedSize: 35,
                        ))
                    : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireDark, size: 120)),
            const SizedBox(height: 14),
                InformationContainer(
                  leadingIcon: FaIcon(FontAwesomeIcons.weightHanging),
                  title: "Training Volume",
                  color:  isDarkMode ? sapphireDark80 : Colors.grey.shade200,
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
}
