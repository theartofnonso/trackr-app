import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Calender extends StatelessWidget {
  const Calender({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [CalendarHeader(), const CalendarDates()],
    );
  }
}

class CalendarHeader extends StatelessWidget {
  CalendarHeader({super.key});

  final List<String> daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"];

  List<Widget> _getHeaders() {
    return daysOfWeek.map((day) => DateWidget(label: day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [..._getHeaders()],
    );
  }
}

class CalendarDates extends StatelessWidget {
  const CalendarDates({super.key});

  List<Widget> _datesToColumns() {
    List<Widget> widgets = [];
    DateTime currentDate = DateTime.now();
    DateTime firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    DateTime lastDayOfMonth =
        DateTime(currentDate.year, currentDate.month + 1, 1);

    // Add padding to start of month
    final isFirstDayNotMonday = firstDayOfMonth.weekday > 1;
    if (isFirstDayNotMonday) {
      final precedingDays = firstDayOfMonth.weekday - 1;
      final emptyWidgets =
          List.filled(precedingDays, const DateWidget(label: ""));
      widgets.addAll(emptyWidgets);
    }

    // Add remainder dates
    for (DateTime date = firstDayOfMonth;
        date.isBefore(lastDayOfMonth);
        date = date.add(const Duration(days: 1))) {
      widgets.add(DateWidget(
        label: date.day.toString(),
      ));
    }

    // Add padding to end of month
    final succeedingDays = 35 - lastDayOfMonth.day;
    final emptyWidgets =
        List.filled(succeedingDays, const DateWidget(label: ""));
    widgets.addAll(emptyWidgets);

    return widgets;
  }

  List<Widget> _dateToRows() {
    List<Widget> widgets = [];
    final dates = _datesToColumns();
    int iterationCount = 6;
    int numbersPerIteration = 7;

    for (int i = 0; i < iterationCount; i++) {
      int startIndex = i * numbersPerIteration;
      int endIndex = (i + 1) * numbersPerIteration;

      if (endIndex > dates.length) {
        endIndex = dates.length;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [...dates.sublist(startIndex, endIndex)],
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._dateToRows()
      ],
    );
  }
}

class DateWidget extends StatelessWidget {
  final String label;

  const DateWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      //color: Colors.grey,
      child: Center(
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}
