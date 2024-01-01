import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/list_tiles/list_tile_solid.dart';

import '../dtos/routine_log_dto.dart';

class _DateViewModel {
  DateTime dateTime;
  DateTime selectedDateTime;

  _DateViewModel({required this.dateTime, required this.selectedDateTime});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentDate = DateTime.now();

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

  List<_DateViewModel?> _generateDates() {
    int year = _currentDate.year;
    int month = _currentDate.month;
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

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      datesInMonths.add(_DateViewModel(dateTime: date, selectedDateTime: _currentDate));
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
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: true);
    final logs = routineLogProvider.logsWhereDate(dateTime: _currentDate).reversed.toList();

    final dates = _generateDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: tealBlueDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: _decrementDate, icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28)),
              Text(_currentDate.formattedMonthAndYear(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  )),
              IconButton(onPressed: _incrementDate, icon: const FaIcon(FontAwesomeIcons.arrowRightLong, color: Colors.white, size: 28)),
            ],
          ),
        ),
        // Container(
        //   color: tealBlueDark,
        //   height: 15,
        // ),
        //_CalendarHeader(),
        _CalenderDates(dates: dates, selectedDateTime: _currentDate, onTap: _selectDate),
        const SizedBox(height: 10),
        if (logs.isNotEmpty) _RoutineLogListView(logs: logs),
        if (logs.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white70),
                      children: const [
                    TextSpan(text: 'Tap'),
                    WidgetSpan(
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white70),
                        alignment: PlaceholderAlignment.middle),
                    TextSpan(text: 'to start logging or visit the + tab to create new workouts'),
                  ]))
            ],
          )
      ],
    );
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
                    width: 45,
                    child: Center(
                      child: Text(day,
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
      return Colors.green;
    }
    return tealBlueLight.withOpacity(0.5);
  }

  Border? _getBorder() {
    final selectedDate = selectedDateTime;
    if (selectedDate.isSameDateAs(dateTime)) {
      return Border.all(color: Colors.white70, width: 2.0);
    } else {
      return null;
    }
  }

  Color _getTextColor(bool hasLog) {
    if (hasLog) {
      return Colors.transparent;
    }
    return Colors.transparent;
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
      splashColor: Colors.transparent,
      onTap: () => onTap(dateTime),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          border: _getBorder(),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: _getBackgroundColor(log != null),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text("${dateTime.day}",
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: _getFontWeight(), color: _getTextColor(log != null))),
          ),
        ),
      ),
    );
  }
}

class _CalenderDates extends StatelessWidget {
  final List<_DateViewModel?> dates;
  final DateTime selectedDateTime;
  final void Function(DateTime dateTime) onTap;

  const _CalenderDates({required this.dates, required this.selectedDateTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    int iterationCount = 6;
    int numbersPerIteration = 7;

    final datesWidgets = dates.map((date) {
      if (date == null) {
        return const SizedBox(width: 45, height: 45);
      } else {
        return _DateWidget(
          dateTime: date.dateTime,
          onTap: onTap,
          selectedDateTime: selectedDateTime,
        );
      }
    }).toList();

    List<Widget> widgets = [];

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
          children: [...datesWidgets.sublist(startIndex, endIndex)],
        ),
      ));
    }

    return Column(children: widgets);
  }
}

class _RoutineLogListView extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const _RoutineLogListView({required this.logs});

  @override
  Widget build(BuildContext context) {
    final widgets = logs.map((log) {
      return _RoutineLogWidget(log: log);
    }).toList();

    return Column(children: widgets);
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLogDto log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    return SolidListTile(
        title: log.name,
        subtitle: "${log.exerciseLogs.length} exercise(s)",
        trailing: log.duration().secondsOrMinutesOrHours(),
        margin: const EdgeInsets.only(bottom: 8.0),
        tileColor: tealBlueLight,
        onTap: () => navigateToRoutineLogPreview(context: context, log: log));
  }
}
