import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';

class _DateViewModel {
  final DateTime dateTime;
  final bool active;

  const _DateViewModel({required this.active, required this.dateTime});
}

class CalendarHeatMap extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final List<DateTime> dates;

  const CalendarHeatMap({super.key, required this.margin, required this.dates});

  List<_DateViewModel?> _generateDates() {
    final firstDate = dates.isNotEmpty ? dates.first : DateTime.now();
    int year = firstDate.year;
    int month = firstDate.month;
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

    // Add dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final active = dates.contains(date);
      datesInMonths.add(_DateViewModel(dateTime: date, active: active));
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

    final datesForMonth = _generateDates();

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Dates(dates: datesForMonth),
        ],
      ),
    );
  }
}

class _DateWidget extends StatelessWidget {
  final _DateViewModel date;

  const _DateWidget({required this.date});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Container(
        decoration: BoxDecoration(
          color: date.active ? Colors.green : tealBlueLighter,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Dates extends StatelessWidget {
  final List<_DateViewModel?> dates;

  const _Dates({required this.dates});

  @override
  Widget build(BuildContext context) {
    int iterationCount = 6;
    int numbersPerIteration = 7;

    final datesWidgets = dates.map((date) {
      if (date == null) {
        return const SizedBox(width: 12, height: 12);
      } else {
        return _DateWidget(date: date);
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

    return SizedBox(width: 110, height: 110, child: Column(children: widgets));
  }
}
