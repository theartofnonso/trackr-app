import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/models/DateTimeEntry.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month);

  void _goToPreviousMonth() {
    final initialDateTime = DateTime(2023, 9);
    if (initialDateTime.isBefore(_currentDate)) {
      setState(() {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              CTextButton(onPressed: _goToPreviousMonth, label: "Prev"),
              const Spacer(),
              Text(_currentDate.formattedMonthAndYear(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              const Spacer(),
              CTextButton(onPressed: _goToNextMonth, label: "Next"),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          CalendarHeader(),
          _CalendarDatesWidgets(
            currentDate: _currentDate,
          ),
        ],
      ),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  CalendarHeader({super.key});

  final List<String> daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ...daysOfWeek
            .map((day) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(day,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ))
            .toList()
      ],
    );
  }
}

class _CalendarDatesWidgets extends StatelessWidget {
  final DateTime currentDate;

  const _CalendarDatesWidgets({required this.currentDate});

  List<Widget> _datesToColumns({required List<DateTimeEntry> dateTimeEntries, required DateTime selectedDate}) {
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
      final emptyWidgets = List.filled(precedingDays, const SizedBox(width: 40, height: 40));
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
      datesInMonths.add(_DateWidget(label: date.day.toString()));
    }

    // Add padding to end of month
    final isLastDayNotSunday = lastDayOfMonth.weekday < 7;
    if (isLastDayNotSunday) {
      final succeedingDays = 7 - lastDayOfMonth.weekday;
      final emptyWidgets = List.filled(succeedingDays, const SizedBox(width: 40, height: 40));
      datesInMonths.addAll(emptyWidgets);
    }

    return datesInMonths;
  }

  List<Widget> _dateToRows({required DateTime selectedDate, required List<DateTimeEntry> dateTimeEntries}) {
    List<Widget> widgets = [];
    final dates = _datesToColumns(selectedDate: selectedDate, dateTimeEntries: dateTimeEntries);
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
    return Column(
      children: [..._dateToRows(selectedDate: DateTime.now(), dateTimeEntries: [])],
    );
  }
}

class _DateWidget extends StatelessWidget {
  final String label;
  final RoutineLog? routineLog;

  const _DateWidget({required this.label, this.routineLog});

  Color _getBackgroundColor() {
    if (routineLog != null) {
      return Colors.white;
    }
    return Colors.transparent;
  }

  Border? _getBorder() {
    if (routineLog != null) {
      return Border.all(color: Colors.grey, width: 1.0);
    }
    return null;
  }

  Color _getTextColor() {
    if (routineLog != null) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: _getBorder(),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: _getTextColor())),
        ),
      ),
    );
  }
}
