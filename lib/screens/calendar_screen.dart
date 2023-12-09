import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/empty_states/list_view_empty_state.dart';

import '../models/RoutineLog.dart';
import '../utils/general_utils.dart';
import '../utils/snackbar_utils.dart';
import 'editors/routine_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _earliestLogDate;

  DateTime _currentDate = DateTime.now();

  bool _hasEarlierDate() {
    int earliestMonth = _earliestLogDate.month;
    int earliestYear = _earliestLogDate.year;
    if (earliestYear == _currentDate.year) {
      return earliestMonth < _currentDate.month;
    } else if (earliestYear < _currentDate.year) {
      return true;
    } else {
      return false;
    }
  }

  bool _hasLaterDate() {
    final laterDate = DateTime.now();
    int laterMonth = laterDate.month;
    int laterYear = laterDate.year;
    if (laterYear == _currentDate.year) {
      return laterMonth > _currentDate.month;
    } else if (laterYear > _currentDate.year) {
      return true;
    } else {
      return false;
    }
  }

  void _decrementDate() {
    if (_hasEarlierDate()) {
      int month = _currentDate.month - 1;
      int year = _currentDate.year;

      /// We need to go to previous year
      if (month == 0) {
        month = 12;
        year = year - 1;
      }

      setState(() {
        _currentDate = DateTime(year, month);
      });
    }
  }

  void _incrementDate() {
    if (_hasLaterDate()) {
      int month = _currentDate.month + 1;
      int year = _currentDate.year;

      /// We need to go to next year
      if (month == 12) {
        month = 0;
        year = year + 1;
      }

      setState(() {
        _currentDate = DateTime(year, month);
      });
    }
  }

  void _selectDate(DateTime dateTime) {
    setState(() {
      _currentDate = dateTime;
    });
  }

  List<Widget> _generateDates() {
    int year = _currentDate.year;
    int month = _currentDate.month;
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
      datesInMonths.add(_DateWidget(
        dateTime: date,
        onTap: (DateTime dateTime) => _selectDate(dateTime),
        selectedDateTime: _currentDate,
      ));
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

  List<Widget> _dateToRows() {
    List<Widget> widgets = [];
    final dates = _generateDates();
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

  void _logEmptyRoutine() {
    final log = cachedRoutineLog();
    if (log == null) {
      navigateToRoutineEditor(
          context: context,
          mode: RoutineEditorMode.log);
    } else {
      showSnackbar(
          context: context,
          icon: const Icon(Icons.info_outline_rounded),
          message: "${log.routine?.name ?? "Workout"} is running");
    }
  }

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: true);
    final logs = routineLogProvider.logsWhereDate(dateTime: _currentDate);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: "fab_routine_logs_screen",
          onPressed: _logEmptyRoutine,
          backgroundColor: tealBlueLighter,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: const Icon(Icons.play_arrow_rounded, size: 32),
        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: tealBlueDark,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CTextButton(onPressed: _decrementDate, label: "Prev"),
                    Text(_currentDate.formattedMonthAndYear(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        )),
                    CTextButton(onPressed: _incrementDate, label: "Next"),
                  ],
                ),
              ),
              Container(
                color: tealBlueDark,
                height: 15,
              ),
              _CalendarHeader(),
              Container(
                color: tealBlueDark,
                child: Column(
                  children: [..._dateToRows()],
                ),
              ),
              Container(
                color: tealBlueDark,
                height: 10,
              ),
              logs.isNotEmpty ? Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) => _RoutineLogWidget(log: logs[index]),
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                    itemCount: logs.length),
              ): const ListViewEmptyState()
            ],
          ),
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

class _CalendarHeader extends StatelessWidget {
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
                    width: 40,
                    child: Center(
                      child: Text(day,
                          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
  final DateTime selectedDateTime;
  final void Function(DateTime dateTime) onTap;

  const _DateWidget({required this.dateTime, required this.selectedDateTime, required this.onTap});

  Color _getBackgroundColor(bool hasLog) {
    if (hasLog) {
      return Colors.white;
    }
    return Colors.transparent;
  }

  Border? _getBorder() {
    final selectedDate = selectedDateTime;
    if (selectedDate.isSameDateAs(dateTime)) {
      return Border.all(color: Colors.white, width: 1.0);
    } else {
      return null;
    }
  }

  Color _getTextColor(bool hasLog) {
    if (hasLog) {
      return Colors.black;
    }
    if (dateTime.isSameDateAs(DateTime.now())) {
      return Colors.white;
    }
    return Colors.white70;
  }

  FontWeight? _getFontWeight() {
    if (dateTime.isSameDateAs(DateTime.now())) {
      return FontWeight.bold;
    }
    return FontWeight.w500;
  }

  @override
  Widget build(BuildContext context) {
    final log = Provider.of<RoutineLogProvider>(context, listen: true).logWhereDate(dateTime: dateTime);
    return InkWell(
      onTap: () => onTap(dateTime),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: _getBorder(),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _getBackgroundColor(log != null),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text("${dateTime.day}",
                style: GoogleFonts.lato(fontSize: 14, fontWeight: _getFontWeight(), color: _getTextColor(log != null))),
          ),
        ),
      ),
    );
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        tileColor: tealBlueLight,
        onTap: () => navigateToRoutineLogPreview(context: context, logId: log.id),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        dense: true,
        title: Text(log.name, style: GoogleFonts.lato(fontSize: 14, color: Colors.white)),
        subtitle: Text("${log.procedures.length} exercise(s)",
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: Text(_logDuration(),
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }

  String _logDuration() {
    String interval = "";
    final startTime = log.startTime.getDateTimeInUtc();
    final endTime = log.endTime.getDateTimeInUtc();
    final difference = endTime.difference(startTime);
    interval = difference.secondsOrMinutesOrHours();
    return interval;
  }
}
