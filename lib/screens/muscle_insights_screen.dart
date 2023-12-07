import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/chart/pie_chart_widget.dart';

import '../app_constants.dart';
import '../enums.dart';
import '../enums/muscle_group_enums.dart';
import '../providers/routine_log_provider.dart';
import '../utils/general_utils.dart';

class MuscleInsightsScreen extends StatefulWidget {
  const MuscleInsightsScreen({super.key});

  @override
  State<MuscleInsightsScreen> createState() => _MuscleInsightsScreenState();
}

class _MuscleInsightsScreenState extends State<MuscleInsightsScreen> {
  ChartTimePeriod _selectedChartTimePeriod = ChartTimePeriod.thisMonth;

  late Map<MuscleGroupFamily, int> _muscleGroupFamily;

  @override
  Widget build(BuildContext context) {
    final bodySplitWidgets = _muscleGroupSplitToWidgets();

    final textStyle = GoogleFonts.lato(fontSize: 14);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: _navigateBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CupertinoSlidingSegmentedControl<ChartTimePeriod>(
            backgroundColor: tealBlueLight,
            thumbColor: Colors.blue,
            groupValue: _selectedChartTimePeriod,
            children: {
              ChartTimePeriod.thisWeek:
                  SizedBox(width: 80, child: Text('This Week', style: textStyle, textAlign: TextAlign.center)),
              ChartTimePeriod.thisMonth:
                  SizedBox(width: 80, child: Text('This Month', style: textStyle, textAlign: TextAlign.center)),
              ChartTimePeriod.thisYear:
                  SizedBox(width: 80, child: Text('This Year', style: textStyle, textAlign: TextAlign.center)),
            },
            onValueChanged: (ChartTimePeriod? value) {
              if (value != null) {
                setState(() {
                  _selectedChartTimePeriod = value;
                  _computeCurrentDatesChart();
                });
              }
            },
          ),
          PieChartWidget(segments: _muscleGroupFamily.entries.take(5).toList()),
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => bodySplitWidgets[index],
                separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
                itemCount: bodySplitWidgets.length),
          )
        ]),
      ),
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  void _calculateBodySplitPercentageForDateRange({required DateTimeRange range}) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

    final Map<MuscleGroupFamily, int> frequencyMap = {};

    // Count the occurrences of each MuscleGroup
    for (MuscleGroupFamily muscleGroupFamily in MuscleGroupFamily.values) {
      frequencyMap[muscleGroupFamily] = routineLogProvider
          .setsForMuscleGroupWhereDateRange(muscleGroupFamily: muscleGroupFamily, range: range)
          .length;
    }

    final sortedBodySplit = frequencyMap.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value));
    setState(() {
      _muscleGroupFamily = Map.fromEntries(sortedBodySplit);
    });
  }

  List<Widget> _muscleGroupSplitToWidgets() {
    final splitList = <Widget>[];
    _muscleGroupFamily.forEach((muscleGroupFamily, count) {
      final widget = Padding(
        key: Key(muscleGroupFamily.name),
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
            dense: true,
            title: Text(muscleGroupFamily.name, style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
            trailing: Text("$count", style: GoogleFonts.lato(color: Colors.white70, fontSize: 14))),
      );
      splitList.add(widget);
    });
    return splitList;
  }

  void _computeCurrentDatesChart() {
    switch (_selectedChartTimePeriod) {
      case ChartTimePeriod.thisWeek:
        final thisWeek = thisWeekDateRange();
        _calculateBodySplitPercentageForDateRange(range: thisWeek);
      case ChartTimePeriod.thisMonth:
        final thisMonth = thisMonthDateRange();
        _calculateBodySplitPercentageForDateRange(range: thisMonth);
      case ChartTimePeriod.thisYear:
        final thisYear = thisYearDateRange();
        _calculateBodySplitPercentageForDateRange(range: thisYear);
      case ChartTimePeriod.allTime:
      // TODO: Handle this case.
    }
  }

  @override
  void initState() {
    super.initState();
    _computeCurrentDatesChart();
  }
}
