import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/chart/pie_chart_widget.dart';

import '../app_constants.dart';
import '../enums/charts_time_period.dart';
import '../enums/muscle_group_enums.dart';
import '../providers/routine_log_provider.dart';
import '../utils/general_utils.dart';

class _MuscleInsightTileViewModel {
  final int index;
  final MapEntry<MuscleGroupFamily, int> muscleGroupFamilyMap;

  _MuscleInsightTileViewModel({required this.index, required this.muscleGroupFamilyMap});
}

class MuscleInsightsScreen extends StatefulWidget {
  const MuscleInsightsScreen({super.key});

  @override
  State<MuscleInsightsScreen> createState() => _MuscleInsightsScreenState();
}

Color generateDecoration({required int index}) {
  return switch (index) {
    0 => Colors.blue,
    1 => Colors.red,
    2 => Colors.green,
    3 => Colors.orange,
    4 => Colors.purple,
    _ => Colors.transparent,
  };
}

class _MuscleInsightsScreenState extends State<MuscleInsightsScreen> {
  ChartTimePeriod _selectedChartTimePeriod = ChartTimePeriod.thisMonth;

  late Map<MuscleGroupFamily, int> _muscleGroupFamily;

  @override
  Widget build(BuildContext context) {
    final bodySplit = _muscleGroupSplitToModels();

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
                  _computeChart();
                });
              }
            },
          ),
          const SizedBox(height: 12),
          PieChartWidget(segments: _muscleGroupFamily.entries.take(5).toList()),
          const SizedBox(height: 12),
          Expanded(
            child: _MuscleInsightListView(models: bodySplit),
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

  List<_MuscleInsightTileViewModel> _muscleGroupSplitToModels() {
    return _muscleGroupFamily.entries
        .mapIndexed((index, muscleGroupFamilyMap) =>
            _MuscleInsightTileViewModel(index: index, muscleGroupFamilyMap: muscleGroupFamilyMap))
        .toList();
  }

  void _computeChart() {
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
    }
  }

  @override
  void initState() {
    super.initState();
    _computeChart();
  }
}

class _MuscleInsightListView extends StatelessWidget {
  final List<_MuscleInsightTileViewModel> models;

  const _MuscleInsightListView({required this.models});

  @override
  Widget build(BuildContext context) {
    final widgets = models.map((model) {
      return _MuscleInsightTile(index: model.index, muscleGroupFamilyMap: model.muscleGroupFamilyMap);
    }).toList();
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => widgets[index],
        separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
        itemCount: widgets.length);
  }
}

class _MuscleInsightTile extends StatelessWidget {
  final int index;
  final MapEntry<MuscleGroupFamily, int> muscleGroupFamilyMap;

  const _MuscleInsightTile({required this.index, required this.muscleGroupFamilyMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: generateDecoration(index: index), width: 2.0)),
      ),
      child: ListTile(
          dense: true,
          title: Text(muscleGroupFamilyMap.key.name, style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
          trailing:
              Text("${muscleGroupFamilyMap.value}", style: GoogleFonts.lato(color: Colors.white70, fontSize: 14))),
    );
  }
}
