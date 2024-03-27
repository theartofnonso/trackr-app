import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../colors.dart';

class CalendarHeatMapEmptyState extends StatelessWidget {
  final List<DateTime> dates;

  const CalendarHeatMapEmptyState({super.key, required this.dates});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dates.first.abbreviatedMonth().toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 1,
            childAspectRatio: 1.2,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: [_CalendarHeatMap(dates: dates)])
      ],
    );
  }
}

class _DateViewModel {
  final DateTime dateTime;

  const _DateViewModel({required this.dateTime});
}

class _CalendarHeatMap extends StatelessWidget {
  final List<DateTime> dates;

  const _CalendarHeatMap({required this.dates});

  List<_DateViewModel?> _generateDates() {
    int year = dates.first.year;
    int month = dates.first.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    List<_DateViewModel?> datesInMonths = [];

    // Add padding to start of month
    final isFirstDayNotMonday = firstDayOfMonth.weekday > 1;
    if (isFirstDayNotMonday) {
      final precedingDays = firstDayOfMonth.weekday - 1;
      final emptyDates = List.filled(precedingDays, null);
      datesInMonths.addAll(emptyDates);
    }

    // Add dates
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
    final datesForMonth = _generateDates();

    return _Month(days: datesForMonth, spacing: 4);
  }
}

class _Month extends StatelessWidget {
  final List<_DateViewModel?> days;
  final double spacing;

  const _Month({required this.days, required this.spacing});

  @override
  Widget build(BuildContext context) {
    final daysWidgets = days.map((day) {
      if (day == null) {
        return const SizedBox();
      } else {
        return _Day(date: day);
      }
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // to disable GridView's scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1, // for square shape
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: daysWidgets.length,
      // Just an example to vary the number of squares
      itemBuilder: (context, index) {
        return daysWidgets[index];
      },
    );
  }
}

class _Day extends StatelessWidget {
  final _DateViewModel date;

  const _Day({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sapphireDark80.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text("${date.dateTime.day}",
            style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
      ),
    );
  }
}
