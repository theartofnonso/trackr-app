import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/DateTimeEntry.dart';
import 'package:tracker_app/providers/datetime_entry_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../utils/snackbar_utils.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month);

  void _goToPreviousMonth({required DateTimeEntry? initialDateTimeEntry}) {
    final initialTemporalDateTime = initialDateTimeEntry?.createdAt;
    if (initialTemporalDateTime != null) {
      final initialDateTime = DateTime(
          initialTemporalDateTime.getDateTimeInUtc().year,
          initialTemporalDateTime.getDateTimeInUtc().month);
      if (initialDateTime.isBefore(_currentDate)) {
        setState(() {
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
        });
      }
    }
  }

  void _goToNextMonth() {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    if (_currentDate.isBefore(now)) {
      setState(() {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      });
    }
  }

  int _calculateNumOfDateEntry({required List<DateTimeEntry> dateTimeEntries}) {
    int year = _currentDate.year;
    int month = _currentDate.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    int numOfDateEntry = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateTimeEntry = dateTimeEntries.firstWhereOrNull((dateTimeEntry) {
        final dateTime = dateTimeEntry.createdAt;
        if (dateTime != null) {
          return dateTime.getDateTimeInUtc().isSameDateAs(other: date);
        }
        return false;
      });
      if (dateTimeEntry != null) {
        numOfDateEntry += 1;
      }
    }

    return numOfDateEntry;
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeEntryProvider =
        Provider.of<DateTimeEntryProvider>(context, listen: true);
    return Container(
      padding: const EdgeInsets.only(top: 20, right: 10, bottom: 20, left: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(12, 14, 18, 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              InkWell(
                splashColor: Colors.transparent,
                onTap: () => _goToPreviousMonth(
                    initialDateTimeEntry:
                        dateTimeEntryProvider.dateTimeEntries.first),
                child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.arrow_circle_left_outlined,
                      color: Colors.white,
                    )),
              ),
              const Spacer(),
              Text(_currentDate.formattedMonthAndYear(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              const Spacer(),
              InkWell(
                splashColor: Colors.transparent,
                onTap: _goToNextMonth,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_circle_right_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          CalendarHeader(),
          CalendarDates(
            currentDate: _currentDate,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const SizedBox(
                width: 6,
              ),
              Text(
                "${_calculateNumOfDateEntry(dateTimeEntries: dateTimeEntryProvider.dateTimeEntries)} times this month",
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70),
              ),
            ],
          )
        ],
      ),
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
  final DateTime currentDate;

  const CalendarDates({super.key, required this.currentDate});

  List<Widget> _datesToColumns(
      {required List<DateTimeEntry> dateTimeEntries,
      required DateTime selectedDate}) {
    int year = currentDate.year;
    int month = currentDate.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    List<Widget> datesInMonths = [];

    // Add padding to start of month
    final isFirstDayNotMonday = firstDayOfMonth.weekday > 1;
    if (isFirstDayNotMonday) {
      final precedingDays = firstDayOfMonth.weekday - 1;
      final emptyWidgets =
          List.filled(precedingDays, const SizedBox(width: 40, height: 40));
      datesInMonths.addAll(emptyWidgets);
    }

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateTimeEntry = dateTimeEntries.firstWhereOrNull((dateTimeEntry) {
        final dateTime = dateTimeEntry.createdAt;
        if (dateTime != null) {
          return dateTime.getDateTimeInUtc().isSameDateAs(other: date);
        }
        return false;
      });
      datesInMonths.add(DateWidget(
        label: date.day.toString(),
        dateTime: date,
        dateTimeEntry: dateTimeEntry,
        isSelected: selectedDate.isSameDateAs(other: date),
      ));
    }

    // Add padding to end of month
    final isLastDayNotSunday = lastDayOfMonth.weekday < 7;
    if (isLastDayNotSunday) {
      final succeedingDays = 7 - lastDayOfMonth.weekday;
      final emptyWidgets =
          List.filled(succeedingDays, const SizedBox(width: 40, height: 40));
      datesInMonths.addAll(emptyWidgets);
    }

    return datesInMonths;
  }

  List<Widget> _dateToRows({
    required DateTime selectedDate,
    required List<DateTimeEntry> dateTimeEntries,
  }) {
    List<Widget> widgets = [];
    final dates = _datesToColumns(
        selectedDate: selectedDate, dateTimeEntries: dateTimeEntries);
    int iterationCount = 6;
    int numbersPerIteration = 7;

    for (int i = 0; i < iterationCount; i++) {
      int startIndex = i * numbersPerIteration;
      int endIndex = (i + 1) * numbersPerIteration;

      if (endIndex > dates.length) {
        endIndex = dates.length;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8.0),
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
    return Consumer<DateTimeEntryProvider>(
        builder: (_, dateTimeEntryProvider, __) {
      return Column(
        children: [
          ..._dateToRows(
              selectedDate: dateTimeEntryProvider.selectedDateTime,
              dateTimeEntries: dateTimeEntryProvider.dateTimeEntries)
        ],
      );
    });
  }
}

class HeaderWidget extends StatelessWidget {
  final String label;

  const HeaderWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}

class DateWidget extends StatefulWidget {
  final String label;
  final DateTime dateTime;
  final DateTimeEntry? dateTimeEntry;
  final bool isSelected;

  const DateWidget(
      {super.key,
      required this.label,
      required this.dateTime,
      this.dateTimeEntry,
      this.isSelected = false});

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  void addNewDateTimeEntry(
      {required BuildContext context, required DateTime? dateTime}) async {
    if (dateTime != null) {
      await Provider.of<DateTimeEntryProvider>(context, listen: false)
          .addDateTimeEntry(dateTime: dateTime);
      if (context.mounted) {
        showSnackbar(
            context: context,
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Colors.black,
            ),
            message: 'Date added successfully');
      }
    }
  }

  void removeDateTimeEntry(
      {required BuildContext context, required DateTimeEntry? entry}) async {
    if (entry != null) {
      await Provider.of<DateTimeEntryProvider>(context, listen: false)
          .removeDateTimeEntry(entryToRemove: entry);
      if (context.mounted) {
        showSnackbar(
            context: context,
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Colors.black,
            ),
            message: 'Date removed successfully');
      }
    }
  }

  void selectDate(
      {required BuildContext context, required DateTime date}) async {
    Provider.of<DateTimeEntryProvider>(context, listen: false)
        .onSelectDate(date: date);
  }

  void selectDateTimeEntry(
      {required BuildContext context, required DateTimeEntry? entry}) async {
    Provider.of<DateTimeEntryProvider>(context, listen: false)
        .onSelectDateEntry(entry: entry);
  }

  void unSelectDateTimeEntry({required BuildContext context}) async {
    Provider.of<DateTimeEntryProvider>(context, listen: false)
        .onRemoveDateEntry();
  }

  Color _getBackgroundColor() {
    if (widget.isSelected) {
      return Colors.white;
    }
    return Colors.transparent;
  }

  Border? _getBorder() {
    if (widget.dateTimeEntry != null) {
      return Border.all(color: Colors.grey, width: 1.0);
    }
    return null;
  }

  Color _getTextColor() {
    if (widget.isSelected) {
      return Colors.black;
    } else if (widget.dateTimeEntry != null) {
      return Colors.grey;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: () {
        if (widget.dateTimeEntry == null) {
          addNewDateTimeEntry(context: context, dateTime: widget.dateTime);
        } else {
          removeDateTimeEntry(context: context, entry: widget.dateTimeEntry);
        }
      },
      onTap: () {
        selectDate(context: context, date: widget.dateTime);
        if (widget.isSelected) {
          unSelectDateTimeEntry(context: context);
        } else {
          selectDateTimeEntry(context: context, entry: widget.dateTimeEntry);
        } // To update the date
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: _getBorder(),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(widget.label,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _getTextColor())),
        ),
      ),
    );
  }
}
