import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/chart/line_chart_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/routine_log_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/sets_and_reps_enum.dart';
import '../../utils/exercise_logs_utils.dart';

class SetsAndRepsInsightsScreen extends StatefulWidget {
  final List<RoutineLogDto>? monthAndLogs;

  const SetsAndRepsInsightsScreen({super.key, this.monthAndLogs});

  @override
  State<SetsAndRepsInsightsScreen> createState() => _SetsAndRepsInsightsScreenState();
}

class _SetsAndRepsInsightsScreenState extends State<SetsAndRepsInsightsScreen> {

  SetAndReps _selectedSetsOrReps = SetAndReps.sets;

  late MuscleGroupFamily _selectedMuscleGroupFamily;

  @override
  Widget build(BuildContext context) {

    final textStyle = GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70);

    final muscleGroups = popularMuscleGroupFamilies();

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final periodicalLogs = routineLogController.weeklyLogs;

    List<int> periodicalValues = [];

    for (var periodAndLogs in periodicalLogs.entries) {
      final valuesForPeriod = periodAndLogs.value
          .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
          .expand((exerciseLogs) => exerciseLogs)
          .where((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup.family == _selectedMuscleGroupFamily)
          .map((log) {
        final values = log.sets.map((set) => _selectedSetsOrReps == SetAndReps.reps ? set.reps() : set.volume()).sum.toInt();
        return values;
      }).sum;

      periodicalValues.add(valuesForPeriod);
    }

    final avgValue = periodicalValues.average.round();

    final chartPoints =
    periodicalValues.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();

    final dateTimes = periodicalLogs.entries.map((monthEntry) => monthEntry.key.end.abbreviatedMonth()).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: sapphireLighter, // Background color
                borderRadius: BorderRadius.circular(5), // Border radius
              ),
              child: DropdownButton<MuscleGroupFamily>(
                menuMaxHeight: 400,
                isExpanded: true,
                isDense: true,
                value: _selectedMuscleGroupFamily,
                hint: Text("Muscle group",
                    style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                underline: Container(
                  color: Colors.transparent,
                ),
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                onChanged: (MuscleGroupFamily? value) {
                  if(value != null) _updateChart(value);
                },
                items: muscleGroups.map<DropdownMenuItem<MuscleGroupFamily>>((MuscleGroupFamily muscleGroup) {
                  return DropdownMenuItem<MuscleGroupFamily>(
                    value: muscleGroup,
                    child: Text(muscleGroup.name,
                        style: GoogleFonts.montserrat(
                            color: _selectedMuscleGroupFamily == muscleGroup ? Colors.white : Colors.white70,
                            fontWeight: _selectedMuscleGroupFamily == muscleGroup ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AVERAGE",
                      style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "$avgValue",
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28),
                        children: [
                          TextSpan(
                            text: " ",
                            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          TextSpan(
                            text: _selectedSetsOrReps.name,
                            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                CupertinoSlidingSegmentedControl<SetAndReps>(
                  backgroundColor: sapphireLighter,
                  thumbColor: sapphireLight,
                  groupValue: _selectedSetsOrReps,
                  children: {
                    SetAndReps.sets: SizedBox(
                        width: 40,
                        child: Text(SetAndReps.sets.name, style: textStyle, textAlign: TextAlign.center)),
                    SetAndReps.reps: SizedBox(
                        width: 40,
                        child: Text(SetAndReps.reps.name, style: textStyle, textAlign: TextAlign.center)),
                  },
                  onValueChanged: (SetAndReps? value) {
                    if (value != null) {
                      setState(() {
                        _selectedSetsOrReps = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: LineChartWidget(
                chartPoints: chartPoints,
                dateTimes: dateTimes,
                unit: ChartUnit.reps,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 150,
                      color: vibrantGreen,
                      strokeWidth: 1.5,
                      strokeCap: StrokeCap.round,
                      dashArray: [10],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: GoogleFonts.montserrat(color: vibrantGreen, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    HorizontalLine(
                      y: 60,
                      color: Colors.orange,
                      strokeWidth: 1.5,
                      strokeCap: StrokeCap.round,
                      dashArray: [10],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: GoogleFonts.montserrat(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    HorizontalLine(
                      y: 30,
                      color: Colors.red,
                      strokeWidth: 1.5,
                      strokeCap: StrokeCap.round,
                      dashArray: [10],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: GoogleFonts.montserrat(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateChart(MuscleGroupFamily muscleGroupFamily) {
    setState(() {
      _selectedMuscleGroupFamily = muscleGroupFamily;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedMuscleGroupFamily = popularMuscleGroupFamilies().first;
  }
}
