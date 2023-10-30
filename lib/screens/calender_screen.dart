import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../models/RoutineLog.dart';
import '../widgets/calendar/routine_log_widget.dart';

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

  void _selectDate(DateTime dateTime) {
    setState(() {
      _currentDate = dateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);
    final logs = routineLogProvider.whereRoutineLogsForDate(dateTime: _currentDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: tealBlueDark,
              child: Row(
                children: [
                  CTextButton(onPressed: _goToPreviousMonth, label: "Prev"),
                  const Spacer(),
                  Text(_currentDate.formattedMonthAndYear(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const Spacer(),
                  CTextButton(onPressed: _goToNextMonth, label: "Next"),
                ],
              ),
            ),
            Container(
              color: tealBlueDark,
              height: 15,
            ),
            CalendarHeader(),
            _ListOfDatesWidgets(
              currentDate: _currentDate,
              logs: routineLogProvider.logs,
              onDateSelected: (DateTime dateTime) => _selectDate(dateTime),
            ),
            Container(
              color: tealBlueDark,
              height: 10,
            ),
            logs.isNotEmpty
                ? Expanded(
                    child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) => RoutineLogWidget(log: logs[index]),
                        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
                        itemCount: logs.length),
                  )
                : Expanded(child: Center(child: CTextButton(onPressed: () {}, label: " Start tracking performance ")))
          ],
        ),
      ),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  CalendarHeader({super.key});

  final List<String> daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tealBlueDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...daysOfWeek
              .map((day) => SizedBox(
                    width: 30,
                    child: Center(
                      child: Text(day,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ))
              .toList()
        ],
      ),
    );
  }
}

class _ListOfDatesWidgets extends StatelessWidget {
  final DateTime currentDate;
  final List<RoutineLog> logs;
  final void Function(DateTime dateTime) onDateSelected;

  const _ListOfDatesWidgets({required this.currentDate, required this.logs, required this.onDateSelected});

  bool _hasLog(DateTime dateTime) {
    final log = logs.firstWhereOrNull((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(other: dateTime));
    return log != null;
  }

  List<Widget> _datesToColumns({required DateTime selectedDate}) {
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
      final emptyWidgets = List.filled(precedingDays, const SizedBox(width: 30, height: 30));
      datesInMonths.addAll(emptyWidgets);
    }

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      datesInMonths.add(_DateWidget(
          label: date.day.toString(), dateTime: date, onTap: (DateTime dateTime) => onDateSelected(dateTime), hasLog: _hasLog(date)));
    }

    // Add padding to end of month
    final isLastDayNotSunday = lastDayOfMonth.weekday < 7;
    if (isLastDayNotSunday) {
      final succeedingDays = 7 - lastDayOfMonth.weekday;
      final emptyWidgets = List.filled(succeedingDays, const SizedBox(width: 30, height: 30));
      datesInMonths.addAll(emptyWidgets);
    }

    return datesInMonths;
  }

  List<Widget> _dateToRows({required DateTime selectedDate}) {
    List<Widget> widgets = [];
    final dates = _datesToColumns(selectedDate: selectedDate);
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [...dates.sublist(startIndex, endIndex)],
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tealBlueDark,
      child: Column(
        children: [..._dateToRows(selectedDate: DateTime.now())],
      ),
    );
  }
}

class _DateWidget extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final bool hasLog;
  final void Function(DateTime dateTime) onTap;

  const _DateWidget({required this.label, required this.hasLog, required this.dateTime, required this.onTap});

  Color _getBackgroundColor() {
    if (hasLog) {
      return Colors.white;
    }
    return Colors.transparent;
  }

  Border? _getBorder() {
    if (hasLog) {
      return Border.all(color: Colors.grey, width: 1.0);
    }
    return null;
  }

  Color _getTextColor() {
    if (hasLog) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(dateTime),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: _getBorder(),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: _getTextColor())),
        ),
      ),
    );
  }
}
