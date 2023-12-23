import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

class _DateViewModel {
  DateTime dateTime;

  _DateViewModel({required this.dateTime});
}

class CalendarHeatMap extends StatefulWidget {
  const CalendarHeatMap({super.key});

  @override
  State<CalendarHeatMap> createState() => _CalendarHeatMapState();
}

class _CalendarHeatMapState extends State<CalendarHeatMap> {
  DateTime _currentDate = DateTime.now();

  List<_DateViewModel?> _generateDates() {
    int year = _currentDate.year;
    int month = _currentDate.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    List<_DateViewModel?> datesInMonths = [];

    // Add padding to start of month
    final isFirstDayNotMonday = firstDayOfMonth.weekday > 1;
    if (isFirstDayNotMonday) {
      final precedingDays = firstDayOfMonth.weekday - 1;
      final emptyDated = List.filled(precedingDays, null);
      datesInMonths.addAll(emptyDated);
    }

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      datesInMonths.add(_DateViewModel(dateTime: date));
    }

    // Add padding to end of month
    final isLastDayNotSunday = lastDayOfMonth.weekday < 7;
    if (isLastDayNotSunday) {
      final succeedingDays = 7 - lastDayOfMonth.weekday;
      final emptyDated = List.filled(succeedingDays, null);
      datesInMonths.addAll(emptyDated);
    }

    return datesInMonths;
  }

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: true);
    final logs = routineLogProvider.logsWhereDate(dateTime: _currentDate);

    final dates = _generateDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CalenderDates(dates: dates, selectedDateTime: _currentDate),
      ],
    );
  }
}

class _DateWidget extends StatelessWidget {
  final DateTime dateTime;
  final DateTime selectedDateTime;

  const _DateWidget({required this.dateTime, required this.selectedDateTime});

  Color _getBackgroundColor(bool hasLog) {
    if (hasLog) {
      return Colors.green;
    }
    return tealBlueLight;
  }

  @override
  Widget build(BuildContext context) {
    final log = Provider.of<RoutineLogProvider>(context, listen: true).logWhereDate(dateTime: dateTime);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _getBackgroundColor(log != null),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class _CalenderDates extends StatelessWidget {
  final List<_DateViewModel?> dates;
  final DateTime selectedDateTime;

  const _CalenderDates({required this.dates, required this.selectedDateTime});

  @override
  Widget build(BuildContext context) {
    int iterationCount = 6;
    int numbersPerIteration = 7;

    final datesWidgets = dates.map((date) {
      if (date == null) {
        return const SizedBox(width: 40, height: 40);
      } else {
        return _DateWidget(
          dateTime: date.dateTime,
          selectedDateTime: selectedDateTime,
        );
      }
    }).toList();

    List<Widget> widgets = [];

    for (int i = 0; i < iterationCount; i++) {
      int startIndex = i * numbersPerIteration;
      int endIndex = (i + 1) * numbersPerIteration;

      if (endIndex > dates.length) {
        endIndex = dates.length;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [...datesWidgets.sublist(startIndex, endIndex)],
        ),
      ));
    }

    return Column(children: widgets);
  }
}
