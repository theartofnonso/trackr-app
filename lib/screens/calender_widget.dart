import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/DateTimeEntry.dart';
import 'package:tracker_app/providers/datetime_entry_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/pulse_animation_container.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DateTimeEntryProvider>(
      builder: (_, dateTimeEntryProvider, __) {
        return Column(
          children: [CalendarHeader(), CalendarDates(dateTimeEntries: dateTimeEntryProvider.dateTimeEntries,)],
        );
      },
    );
  }
}

class CalendarHeader extends StatelessWidget {
  CalendarHeader({super.key});

  final List<String> daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"];

  List<Widget> _getHeaders() {
    return daysOfWeek.map((day) => HeaderWidget(label: day)).toList();
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

  final List<DateTimeEntry> dateTimeEntries;

  const CalendarDates({super.key, required this.dateTimeEntries});

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
        dateTime: date,
        dateTimeEntry: dateTimeEntries.firstWhereOrNull((dateTimeEntry) => dateTimeEntry.createdAt!.getDateTimeInUtc().isSameDateAs(dateTimeToCompare: date)))
      );
    }

    // Add padding to end of month
    final succeedingDays = 35 - lastDayOfMonth.day;
    final emptyWidgets =
        List.filled(succeedingDays, const DateWidget(label: "", dateTime: null,));
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
        padding: const EdgeInsets.symmetric(vertical: 10.0),
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
      children: [..._dateToRows()],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String label;

  const HeaderWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      //color: Colors.transparent,
      padding: const EdgeInsets.all(8.0),
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

class DateWidget extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final DateTimeEntry? dateTimeEntry;

  const DateWidget(
      {super.key,
      required this.label, this.dateTime, this.dateTimeEntry});

  @override
  Widget build(BuildContext context) {

    final isCurrentDay = dateTime?.isNow() ?? false;

    return isCurrentDay
        ? DateMarkerWidget(
            label: label,
          )
        : Container(
            width: 50,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: dateTimeEntry != null ? Border.all(
                color: Colors.grey, // Set the border color here
                width: 1.0, // Set the border width
              ) : null,
              borderRadius: BorderRadius.circular(
                  5), // Adjust the radius as per your requirement
            ),
            child: Center(
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: dateTimeEntry != null ? Colors.grey : Colors.white)),
            ),
          );
  }
}

class DateMarkerWidget extends StatelessWidget {
  final String label;
  final void Function()? onPressed;

  const DateMarkerWidget({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        splashColor: Colors.transparent,
        child: PulsatingWidget(
          child: Container(
            width: 50,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(
                  5), // Adjust the radius as per your requirement
            ),
            child: Center(
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
          ),
        ));
  }
}
