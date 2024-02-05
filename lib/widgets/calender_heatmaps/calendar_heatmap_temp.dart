import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';

class _DateViewModel {
  DateTime dateTime;

  _DateViewModel({required this.dateTime});
}

class CalendarHeatMap extends StatelessWidget {
  final DateTime _currentDate = DateTime.now();

  CalendarHeatMap({super.key});

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
    final dates = _generateDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CalenderDates(dates: dates),
      ],
    );
  }
}

class _DateWidget extends StatelessWidget {
  final DateTime dateTime;

  const _DateWidget({required this.dateTime});

  Color _getBackgroundColor(bool hasLog) {
    if (hasLog) {
      return vibrantGreen;
    }
    return sapphireLighter;
  }

  @override
  Widget build(BuildContext context) {
    final log = Provider.of<RoutineLogController>(context, listen: true).logWhereDate(dateTime: dateTime);
    return SizedBox(
      width: 16,
      height: 16,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(log != null),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _CalenderDates extends StatelessWidget {
  final List<_DateViewModel?> dates;

  const _CalenderDates({required this.dates});

  @override
  Widget build(BuildContext context) {
    int iterationCount = 6;
    int numbersPerIteration = 7;

    final datesWidgets = dates.map((date) {
      if (date == null) {
        return const SizedBox(width: 16, height: 16);
      } else {
        return _DateWidget(dateTime: date.dateTime);
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

    return SizedBox(width: 140, height: 140, child: Column(children: widgets));
  }
}
