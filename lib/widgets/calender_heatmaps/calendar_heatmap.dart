import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';

class _DateViewModel {
  final DateTime dateTime;
  final bool active;
  final Color color;

  const _DateViewModel({required this.active, required this.dateTime, required this.color});

  @override
  String toString() {
    return '_DateViewModel{dateTime: $dateTime, active: $active, color: $color}';
  }
}

class CalendarHeatMap extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime initialDate;
  final double spacing;
  final bool dynamicColor;
  final bool showMonth;
  final bool minifyLabels;

  const CalendarHeatMap(
      {super.key,
      required this.initialDate,
      required this.dates,
      this.spacing = 16,
      this.dynamicColor = false,
      this.showMonth = true, this.minifyLabels = false});

  List<_DateViewModel?> _generateDates() {
    int year = initialDate.year;
    int month = initialDate.month;
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
      final active = dates.contains(date);
      final color = dates.isNotEmpty ? consistencyHealthColor(value: dates.length / 12) : sapphireDark;
      datesInMonths.add(_DateViewModel(dateTime: date, active: active, color: dynamicColor ? color : vibrantGreen));
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMonth)
          Text(initialDate.abbreviatedMonth().toUpperCase(),
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        _Month(days: datesForMonth, spacing: spacing, minifyLabels: minifyLabels,),
      ],
    );
  }
}

class _Month extends StatelessWidget {
  final List<_DateViewModel?> days;
  final double spacing;
  final bool minifyLabels;

  const _Month({required this.days, required this.spacing, required this.minifyLabels});

  @override
  Widget build(BuildContext context) {
    final daysWidgets = days.map((day) {
      if (day == null) {
        return const SizedBox();
      } else {
        return _Day(date: day, minifyLabels: minifyLabels);
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
  final bool minifyLabels;

  const _Day({required this.date, required this.minifyLabels});

  Color _getTextColor() {
    return date.active ? Colors.black : Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: date.active ? date.color : sapphireDark80.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text("${date.dateTime.day}",
            style: GoogleFonts.montserrat(fontSize: minifyLabels ? 12 : 16, fontWeight: FontWeight.bold, color: _getTextColor())),
      ),
    );
  }
}
