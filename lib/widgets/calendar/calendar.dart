import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/settings_controller.dart';

GlobalKey calendarKey = GlobalKey();

class _DateViewModel {
  final DateTime dateTime;
  final DateTime selectedDateTime;
  final bool hasRoutineLog;
  final bool hasActivityLog;

  _DateViewModel(
      {required this.dateTime,
      required this.selectedDateTime,
      this.hasRoutineLog = false,
      this.hasActivityLog = false});

  @override
  String toString() {
    return '_DateViewModel{dateTime: $dateTime, selectedDateTime: $selectedDateTime, hasLog: $hasRoutineLog, hasActivityLog: $hasActivityLog}';
  }
}

class Calendar extends StatefulWidget {
  final void Function(DateTime dateTime)? onSelectDate;
  final DateTime dateTime;

  const Calendar({super.key, this.onSelectDate, required this.dateTime});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _currentDate = DateTime.now();

  void _selectDate(DateTime dateTime) {
    final onSelectDate = widget.onSelectDate;
    if (onSelectDate != null) {
      onSelectDate(dateTime);
    }
    setState(() {
      _currentDate = dateTime;
    });
  }

  List<_DateViewModel?> _generateDates() {
    final startDate = widget.dateTime;

    int year = startDate.year;
    int month = startDate.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    List<_DateViewModel?> datesInMonths = [];

    // Add padding to start of month
    final isFirstDayNotMonday = firstDayOfMonth.weekday > 1;
    if (isFirstDayNotMonday) {
      final precedingDays = firstDayOfMonth.weekday - 1;
      final emptyDated = List.filled(precedingDays, null);
      datesInMonths.addAll(emptyDated);
    }

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final activityLogController = Provider.of<ActivityLogController>(context, listen: false);

    final monthlyRoutineLogs = (routineLogController.logs
            .where((log) => log.createdAt.isBetweenInclusive(from: firstDayOfMonth, to: lastDayOfMonth)))
        .map((log) => DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day));

    final monthlyActivityLogs = (activityLogController.logs
            .where((log) => log.createdAt.isBetweenInclusive(from: firstDayOfMonth, to: lastDayOfMonth)))
        .map((log) => DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day));

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final hasRoutineLog = monthlyRoutineLogs.contains(date);
      final hasActivityLog = monthlyActivityLogs.contains(date);
      datesInMonths.add(_DateViewModel(
          dateTime: date,
          selectedDateTime: _currentDate.withoutTime(),
          hasRoutineLog: hasRoutineLog,
          hasActivityLog: hasActivityLog));
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
    Provider.of<SettingsController>(context, listen: true);

    final dates = _generateDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SharedPrefs().showCalendarDates
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _CalendarHeader(),
              )
            : const SizedBox(height: 8),
        _Month(dates: dates, selectedDateTime: _currentDate.withoutTime(), onTap: _selectDate),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> daysOfWeek = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

    return SizedBox(
        height: 25,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1, // for square shape
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: daysOfWeek.length, // Just an example to vary the number of squares
          itemBuilder: (context, index) {
            return Text(daysOfWeek[index],
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center);
          },
        ));
  }
}

class _Month extends StatelessWidget {
  final List<_DateViewModel?> dates;
  final DateTime selectedDateTime;
  final void Function(DateTime dateTime) onTap;

  const _Month({required this.dates, required this.selectedDateTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final datesWidgets = dates.map((date) {
      if (date == null) {
        return const SizedBox();
      } else {
        return _Day(
          dateTime: date.dateTime,
          onTap: onTap,
          selected: date.dateTime.isSameDayMonthYear(selectedDateTime),
          currentDate: date.dateTime.isSameDayMonthAndYear(DateTime.now()),
          hasRoutineLog: date.hasRoutineLog,
          hasActivityLog: date.hasActivityLog,
        );
      }
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // to disable GridView's scrolling
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1, // for square shape
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: datesWidgets.length,
      // Just an example to vary the number of squares
      itemBuilder: (context, index) {
        return datesWidgets[index];
      },
    );
  }
}

class _Day extends StatelessWidget {
  final DateTime dateTime;
  final bool selected;
  final bool hasRoutineLog;
  final bool hasActivityLog;
  final bool currentDate;
  final void Function(DateTime dateTime) onTap;

  const _Day(
      {required this.dateTime,
      required this.selected,
      required this.currentDate,
      required this.onTap,
      this.hasRoutineLog = false,
      this.hasActivityLog = false});

  Color _getBackgroundColor({required bool isDarkMode}) {
    if (hasRoutineLog) {
      return isDarkMode ? vibrantGreen.withValues(alpha:0.1) : vibrantGreen;
    }
    if (hasActivityLog) {
      return isDarkMode ? Colors.greenAccent.withValues(alpha:0.1) : Colors.greenAccent;
    } else {
      return isDarkMode ? sapphireDark80.withValues(alpha:0.5) : Colors.grey.shade200;
    }
  }

  Color _getTextColor({required bool isDarkMode}) {
    if (hasRoutineLog) {
      return isDarkMode ? vibrantGreen : Colors.black;
    }
    if (hasActivityLog) {
      return isDarkMode ? Colors.greenAccent : Colors.black;
    } else {
      return isDarkMode ? Colors.white : Colors.black;
    }
  }

  Border? _dateBorder() {
    if (selected) {
      return Border.all(color: Colors.blueGrey, width: 2.0);
    } else if (currentDate) {
      return Border.all(color: Colors.grey, width: 2.0);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(dateTime),
      child: Container(
        padding: selected ? const EdgeInsets.all(2) : null,
        decoration: BoxDecoration(
          border: _dateBorder(),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getBackgroundColor(isDarkMode: isDarkMode),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text("${dateTime.day}",
                style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.bold, color: _getTextColor(isDarkMode: isDarkMode))),
          ),
        ),
      ),
    );
  }
}
