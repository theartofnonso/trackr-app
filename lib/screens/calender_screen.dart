import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/routine_logs_screen.dart';
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

  late DateTime _earliestLogDate;

  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month);
  
  bool _hasEarlierDate() {
    return _earliestLogDate.isBefore(_currentDate);
  }

  bool _hasLaterDate() {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    return _currentDate.isBefore(now);
  }

  void _goToPreviousMonth() {
    if (_hasEarlierDate()) {
      setState(() {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      });
    }
  }

  void _goToNextMonth() {
    if (_hasLaterDate()) {
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
                  _hasEarlierDate() ? CTextButton(onPressed: _goToPreviousMonth, label: "Prev") : const SizedBox.shrink(),
                  Expanded(
                    child: Text(_currentDate.formattedMonthAndYear(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  _hasLaterDate() ? CTextButton(onPressed: _goToNextMonth, label: "Next") : const SizedBox.shrink(),
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
                : Expanded(
                    child: Center(
                        child: CTextButton(
                            onPressed: () =>
                                navigateToRoutineEditor(context: context, createdAt: TemporalDateTime.now()),
                            label: " Start tracking performance ")))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final earliestRoutineLog = Provider.of<RoutineLogProvider>(context, listen: false).logs.lastOrNull;
    final earliestDateTime =
        earliestRoutineLog != null ? earliestRoutineLog.createdAt.getDateTimeInUtc() : _currentDate;
    _earliestLogDate = DateTime(earliestDateTime.year, earliestDateTime.month);
  }
}

class _ListOfDatesWidgets extends StatefulWidget {
  final DateTime currentDate;
  final List<RoutineLog> logs;
  final void Function(DateTime dateTime) onDateSelected;

  const _ListOfDatesWidgets({required this.currentDate, required this.logs, required this.onDateSelected});

  @override
  State<_ListOfDatesWidgets> createState() => _ListOfDatesWidgetsState();
}

class _ListOfDatesWidgetsState extends State<_ListOfDatesWidgets> {
  DateTime? _selectedDate;

  void _selectDate(DateTime dateTime) {
    widget.onDateSelected(dateTime);
    setState(() {
      _selectedDate = dateTime;
    });
  }

  bool _hasLog(DateTime dateTime) {
    final log = widget.logs.firstWhereOrNull((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(other: dateTime));
    return log != null;
  }

  List<Widget> _datesToColumns({required DateTime selectedDate}) {
    int year = widget.currentDate.year;
    int month = widget.currentDate.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    List<Widget> datesInMonths = [];

    // Add padding to start of month
    final isFirstDayNotMonday = firstDayOfMonth.weekday > 1;
    if (isFirstDayNotMonday) {
      final precedingDays = firstDayOfMonth.weekday - 1;
      final emptyWidgets = List.filled(precedingDays, const SizedBox(width: 45, height: 45));
      datesInMonths.addAll(emptyWidgets);
    }

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      datesInMonths.add(_DateWidget(
        dateTime: date,
        onTap: (DateTime dateTime) => _selectDate(dateTime),
        hasLog: _hasLog(date),
        selectedDateTime: _selectedDate,
      ));
    }

    // Add padding to end of month
    final isLastDayNotSunday = lastDayOfMonth.weekday < 7;
    if (isLastDayNotSunday) {
      final succeedingDays = 7 - lastDayOfMonth.weekday;
      final emptyWidgets = List.filled(succeedingDays, const SizedBox(width: 45, height: 45));
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
            width: 45,
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

class _DateWidget extends StatelessWidget {
  final DateTime dateTime;
  final DateTime? selectedDateTime;
  final bool hasLog;
  final void Function(DateTime dateTime) onTap;

  const _DateWidget({required this.dateTime, required this.selectedDateTime, required this.hasLog, required this.onTap});

  Color _getBackgroundColor() {
    if (hasLog) {
      return Colors.white;
    }
    return Colors.transparent;
  }

  Border? _getBorder() {
    final selectedDate = selectedDateTime;
    if (selectedDate != null) {
      if (selectedDate.isAtSameMomentAs(dateTime)) {
        return Border.all(color: Colors.white, width: 1.0);
      }
    }
    return null;
  }

  Color _getTextColor() {
    if (hasLog) {
      return Colors.black;
    }
    if (dateTime.isSameDateAs(other: DateTime.now())) {
      return Colors.white;
    }
    return Colors.white70;
  }

  FontWeight? _getFontWeight() {
    if (dateTime.isSameDateAs(other: DateTime.now())) {
      return FontWeight.bold;
    }
    return FontWeight.w500;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(dateTime),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: _getBorder(),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text("${dateTime.day}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: _getFontWeight(), color: _getTextColor())),
        ),
      ),
    );
  }
}
