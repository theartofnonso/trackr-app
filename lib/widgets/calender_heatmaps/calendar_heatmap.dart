import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

class _DateViewModel {
  final DateTime dateTime;
  final bool active;

  const _DateViewModel({required this.active, required this.dateTime});

  @override
  String toString() {
    return '_DateViewModel{dateTime: $dateTime, active: $active}';
  }
}

class CalendarHeatMap extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime initialDate;

  const CalendarHeatMap({super.key, required this.initialDate, required this.dates});

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

    return _Month(days: datesForMonth, initialDate: initialDate);
  }
}

class _Day extends StatelessWidget {
  final _DateViewModel date;

  const _Day({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: date.active ? Colors.green : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _Month extends StatelessWidget {
  final List<_DateViewModel?> days;
  final DateTime initialDate;

  const _Month({required this.days, required this.initialDate});

  @override
  Widget build(BuildContext context) {
    final daysWidgets = days.map((day) {
      if (day == null) {
        return const SizedBox();
      } else {
        return _Day(date: day);
      }
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(initialDate.abbreviatedMonth().toUpperCase(),
          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
      Expanded(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1, // for square shape
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: daysWidgets.length, // Just an example to vary the number of squares
          itemBuilder: (context, index) {
            return daysWidgets[index];
          },
        ),
      )
    ]);
  }
}
