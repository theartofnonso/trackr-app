import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/BodyPart.dart';
import 'package:tracker_app/screens/profile_screen.dart';
import 'package:tracker_app/widgets/chart/pie_chart_widget.dart';

import '../app_constants.dart';
import '../enums.dart';
import '../providers/routine_log_provider.dart';

class MuscleDistributionScreen extends StatefulWidget {
  const MuscleDistributionScreen({super.key});

  @override
  State<MuscleDistributionScreen> createState() => _MuscleDistributionScreenState();
}

class _MuscleDistributionScreenState extends State<MuscleDistributionScreen> with SingleTickerProviderStateMixin {
  HistoricalTimePeriod _selectedHistoricalDate = HistoricalTimePeriod.lastThreeMonths;

  CurrentTimePeriod _selectedCurrentTimePeriod = CurrentTimePeriod.allTime;

  List<MapEntry<String, int>> _bodySplits = [];

  @override
  Widget build(BuildContext context) {
    final splitMap = Map.fromEntries(_bodySplits);

    final bodySplit = _bodyPartSplit(splitMap);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
        title: const Text("Muscle Distribution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: _navigateBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            DropdownButton<String>(
              isDense: true,
              value: _selectedCurrentTimePeriod.label,
              underline: Container(
                color: Colors.transparent,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrentTimePeriod = switch (value) {
                      "This Week" => CurrentTimePeriod.thisWeek,
                      "This Month" => CurrentTimePeriod.thisMonth,
                      "This Year" => CurrentTimePeriod.thisYear,
                      _ => CurrentTimePeriod.allTime
                    };
                    _recomputeCurrentDatesChart();
                  });
                }
              },
              items: CurrentTimePeriod.values.map<DropdownMenuItem<String>>((CurrentTimePeriod currentTimePeriod) {
                return DropdownMenuItem<String>(
                  value: currentTimePeriod.label,
                  child: Text(currentTimePeriod.label, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              isDense: true,
              value: _selectedHistoricalDate.label,
              underline: Container(
                color: Colors.transparent,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                if (value != null) {
                  setState(() {
                    _selectedHistoricalDate = switch (value) {
                      "Last 3 months" => HistoricalTimePeriod.lastThreeMonths,
                      "Last 1 year" => HistoricalTimePeriod.lastOneYear,
                      "All Time" => HistoricalTimePeriod.allTime,
                      _ => HistoricalTimePeriod.allTime
                    };
                    _recomputeHistoricalDatesChart();
                  });
                }
              },
              items: HistoricalTimePeriod.values.map<DropdownMenuItem<String>>((HistoricalTimePeriod historicalDate) {
                return DropdownMenuItem<String>(
                  value: historicalDate.label,
                  child: Text(historicalDate.label, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            )
          ]),
          PieChartWidget(segments: _bodySplits.take(5).toList()),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => bodySplit[index],
                separatorBuilder: (BuildContext context, int index) => const SizedBox(),
                itemCount: bodySplit.length),
          )
          //..._bodyPartSplit(provider: routineLogProvider)],
        ]),
      ),
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  void _calculateBodySplitPercentageForDateRange({DateTimeRange? range}) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

    const bodyParts = BodyPart.values;

    final Map<BodyPart, int> frequencyMap = {};

    // Count the occurrences of each bodyPart
    for (BodyPart bodyPart in bodyParts) {
      frequencyMap[bodyPart] = range != null
          ? routineLogProvider
              .setDtosForBodyPartWhereDateRange(bodyPart: bodyPart, context: context, range: range)
              .length
          : routineLogProvider.whereSetDtos(bodyPart: bodyPart, context: context).length;
    }

    final Map<String, int> percentageMap = {};

    // Calculate the percentage for each bodyPart
    frequencyMap.forEach((item, count) {
      percentageMap[item.name] = count;
    });

    setState(() {
      _bodySplits = percentageMap.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value));
    });
  }

  void _calculateBodySplitPercentageSince({int? since}) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

    const bodyParts = BodyPart.values;

    final Map<BodyPart, int> frequencyMap = {};

    // Count the occurrences of each bodyPart
    for (BodyPart bodyPart in bodyParts) {
      frequencyMap[bodyPart] = since != null
          ? routineLogProvider
              .setDtosForBodyPartWhereDateRangeSince(bodyPart: bodyPart, context: context, since: since)
              .length
          : routineLogProvider.whereSetDtos(bodyPart: bodyPart, context: context).length;
    }

    final Map<String, int> percentageMap = {};

    // Calculate the percentage for each bodyPart
    frequencyMap.forEach((item, count) {
      percentageMap[item.name] = count;
    });

    setState(() {
      _bodySplits = percentageMap.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value));
    });
  }

  List<Widget> _bodyPartSplit(Map<String, int> splitMap) {
    final splitList = <Widget>[];
    splitMap.forEach((key, value) {
      final widget = Padding(
        key: Key(key),
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
            tileColor: tealBlueLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0), // Adjust the border radius as needed
            ),
            title: Text(key, style: Theme.of(context).textTheme.labelLarge),
            trailing: Text("$value", style: Theme.of(context).textTheme.labelLarge)),
      );
      splitList.add(widget);
    });
    return splitList;
  }

  void _recomputeCurrentDatesChart() {
    switch (_selectedCurrentTimePeriod) {
      case CurrentTimePeriod.thisWeek:
        final thisWeek = thisWeekDateRange();
        _calculateBodySplitPercentageForDateRange(range: thisWeek);
      case CurrentTimePeriod.thisMonth:
        final thisMonth = thisMonthDateRange();
        _calculateBodySplitPercentageForDateRange(range: thisMonth);
      case CurrentTimePeriod.thisYear:
        final thisYear = thisYearDateRange();
        _calculateBodySplitPercentageForDateRange(range: thisYear);
      case CurrentTimePeriod.allTime:
        _calculateBodySplitPercentageForDateRange();
    }
  }

  void _recomputeHistoricalDatesChart() {
    switch (_selectedHistoricalDate) {
      case HistoricalTimePeriod.lastThreeMonths:
        _calculateBodySplitPercentageSince(since: 90);
      case HistoricalTimePeriod.lastOneYear:
        _calculateBodySplitPercentageSince(since: 365);
      case HistoricalTimePeriod.allTime:
        _calculateBodySplitPercentageSince();
    }
  }

  @override
  void initState() {
    super.initState();
    _recomputeHistoricalDatesChart();
  }
}
