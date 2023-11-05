import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  CurrentTimePeriod _selectedCurrentTimePeriod = CurrentTimePeriod.thisMonth;

  late Map<BodyPart, int> _bodySplit;

  @override
  Widget build(BuildContext context) {

    final bodySplitWidgets = _bodyPartSplitToWidgets();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
        title: Text("Muscle Distribution", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600)),
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
              style: GoogleFonts.lato(color: Colors.white),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrentTimePeriod = switch (value) {
                      "This Week" => CurrentTimePeriod.thisWeek,
                      "This Month" => CurrentTimePeriod.thisMonth,
                      "This Year" => CurrentTimePeriod.thisYear,
                      _ => CurrentTimePeriod.allTime
                    };
                    _computeCurrentDatesChart();
                  });
                }
              },
              items: CurrentTimePeriod.values.map<DropdownMenuItem<String>>((CurrentTimePeriod currentTimePeriod) {
                return DropdownMenuItem<String>(
                  value: currentTimePeriod.label,
                  child: Text(currentTimePeriod.label, style: GoogleFonts.lato(fontSize: 12)),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              isDense: true,
              value: _selectedHistoricalDate.label,
              underline: Container(
                color: Colors.transparent,
              ),
              style: GoogleFonts.lato(color: Colors.white),
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
                    _computeHistoricalDatesChart();
                  });
                }
              },
              items: HistoricalTimePeriod.values.map<DropdownMenuItem<String>>((HistoricalTimePeriod historicalDate) {
                return DropdownMenuItem<String>(
                  value: historicalDate.label,
                  child: Text(historicalDate.label, style: GoogleFonts.lato(fontSize: 12)),
                );
              }).toList(),
            )
          ]),
          PieChartWidget(segments: _bodySplit.entries.take(5).toList()),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => bodySplitWidgets[index],
                separatorBuilder: (BuildContext context, int index) => const SizedBox(),
                itemCount: bodySplitWidgets.length),
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

    final Map<BodyPart, int> frequencyMap = {};

    // Count the occurrences of each bodyPart
    for (BodyPart bodyPart in BodyPart.values) {
      frequencyMap[bodyPart] = range != null
          ? routineLogProvider
              .setDtosForBodyPartWhereDateRange(bodyPart: bodyPart, context: context, range: range)
              .length
          : routineLogProvider.whereSetDtosForBodyPart(bodyPart: bodyPart, context: context).length;
    }

    final sortedBodySplit = frequencyMap.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value));
    setState(() {
      _bodySplit = Map.fromEntries(sortedBodySplit);
    });
  }

  void _calculateBodySplitPercentageSince({int? since}) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

    final Map<BodyPart, int> frequencyMap = {};

    // Count the occurrences of each bodyPart
    for (BodyPart bodyPart in BodyPart.values) {
      frequencyMap[bodyPart] = since != null
          ? routineLogProvider
              .whereSetDtosForBodyPartSince(bodyPart: bodyPart, context: context, since: since)
              .length
          : routineLogProvider.whereSetDtosForBodyPart(bodyPart: bodyPart, context: context).length;
    }

    final sortedBodySplit = frequencyMap.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value));
    setState(() {
      _bodySplit = Map.fromEntries(sortedBodySplit);
    });
  }

  List<Widget> _bodyPartSplitToWidgets() {
    final splitList = <Widget>[];
    _bodySplit.forEach((bodyPart, count) {
      final widget = Padding(
        key: Key(bodyPart.name),
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
            tileColor: tealBlueLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0), // Adjust the border radius as needed
            ),
            title: Text(bodyPart.name, style: Theme.of(context).textTheme.labelLarge),
            trailing: Text("$count", style: Theme.of(context).textTheme.labelLarge)),
      );
      splitList.add(widget);
    });
    return splitList;
  }

  void _computeCurrentDatesChart() {
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

  void _computeHistoricalDatesChart() {
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
    _computeHistoricalDatesChart();
  }
}
