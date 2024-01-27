import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/pbs/pb_icon.dart';
import 'package:tracker_app/widgets/list_tiles/list_tile_solid.dart';

import '../../controllers/settings_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';

GlobalKey calendarKey = GlobalKey();

class _DateViewModel {
  final DateTime dateTime;
  final DateTime selectedDateTime;
  final bool hasLog;

  _DateViewModel({required this.dateTime, required this.selectedDateTime, required this.hasLog});
}

class Calendar extends StatefulWidget {
  
  final bool readOnly;

  const Calendar({super.key, this.readOnly = false});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
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

    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final logsForCurrentDate =
        (routineLogController.monthlyLogs[DateTimeRange(start: firstDayOfMonth, end: lastDayOfMonth)] ?? [])
            .map((log) => DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day));

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final hasLog = logsForCurrentDate.contains(date);
      datesInMonths.add(_DateViewModel(dateTime: date, selectedDateTime: _currentDate, hasLog: hasLog));
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
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);
    final logsForCurrentDate = routineLogController.logsWhereDate(dateTime: _currentDate).reversed.toList();

    final dates = _generateDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(!widget.readOnly)
              IconButton(
                onPressed: _decrementDate,
                icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28)),
            Expanded(
              child: Text(_currentDate.formattedMonthAndYear(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  )),
            ),
            if(!widget.readOnly)
              IconButton(
                onPressed: _incrementDate,
                icon: _hasLaterDate()
                    ? const FaIcon(FontAwesomeIcons.arrowRightLong, color: Colors.white, size: 28)
                    : const SizedBox()),
          ],
        ),
        SharedPrefs().showCalendarDates
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _CalendarHeader(),
              )
            : const SizedBox(height: 8),
        _Month(dates: dates, selectedDateTime: _currentDate, onTap: _selectDate, readOnly: widget.readOnly),
        const SizedBox(height: 10),
        if (logsForCurrentDate.isNotEmpty && !widget.readOnly) _RoutineLogListView(logs: logsForCurrentDate),
        if (logsForCurrentDate.isEmpty && !widget.readOnly)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                      children: const [
                    TextSpan(text: 'Tap'),
                    WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: FaIcon(
                            FontAwesomeIcons.play,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        alignment: PlaceholderAlignment.middle),
                    TextSpan(text: 'to start logging or visit the'),
                    WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: FaIcon(
                            FontAwesomeIcons.dumbbell,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        alignment: PlaceholderAlignment.middle),
                    TextSpan(text: 'tab to create workout templates'),
                  ]))
            ],
          )
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
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: daysOfWeek.length, // Just an example to vary the number of squares
          itemBuilder: (context, index) {
            return Text(daysOfWeek[index],
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                textAlign: TextAlign.center);
          },
        ));
  }
}

class _Month extends StatelessWidget {
  final List<_DateViewModel?> dates;
  final DateTime selectedDateTime;
  final bool readOnly;
  final void Function(DateTime dateTime) onTap;

  const _Month({required this.dates, required this.selectedDateTime, required this.onTap, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    final datesWidgets = dates.map((date) {
      if (date == null) {
        return const SizedBox();
      } else {
        return _Day(
          dateTime: date.dateTime,
          onTap: onTap,
          selectedDateTime: selectedDateTime,
          showSelector: !readOnly,
          hasLog: date.hasLog,
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
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 14.0,
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
  final DateTime selectedDateTime;
  final bool showSelector;
  final bool hasLog;
  final void Function(DateTime dateTime) onTap;

  const _Day(
      {required this.dateTime,
        required this.selectedDateTime,
        required this.onTap,
        required this.showSelector,
        required this.hasLog});

  Color _getBackgroundColor() {
    return hasLog ? vibrantGreen : tealBlueLight.withOpacity(0.5);
  }

  Border? _getBorder() {
    final selectedDate = selectedDateTime;
    if (selectedDate.isSameDateAs(dateTime)) {
      return Border.all(color: Colors.white70, width: 2.0);
    } else {
      return null;
    }
  }

  Color _getTextColor() {
    if (SharedPrefs().showCalendarDates) {
      return hasLog ? Colors.black : Colors.white70;
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
    return GestureDetector(
      onTap: () => onTap(dateTime),
      child: Container(
        padding: selectedDateTime.isSameDateAs(dateTime) && showSelector ? const EdgeInsets.all(4) : null,
        decoration: showSelector
            ? BoxDecoration(
          border: _getBorder(),
          borderRadius: BorderRadius.circular(5),
        )
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text("${dateTime.day}",
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: _getFontWeight(), color: _getTextColor())),
          ),
        ),
      ),
    );
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
    final provider = Provider.of<RoutineLogController>(context, listen: false);

    final pbs = log.exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
          provider.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    return SolidListTile(
        title: log.name,
        subtitle: "${log.exerciseLogs.length} ${pluralize(word: "exercise", count: log.exerciseLogs.length)}",
        trailing: log.duration().hmsAnalog(),
        trailingSubtitle: pbs.isNotEmpty ? PBIcon(color: tealBlueLight, label: "${pbs.length}") : null,
        margin: const EdgeInsets.only(bottom: 8.0),
        tileColor: tealBlueLight,
        onTap: () => navigateToRoutineLogPreview(context: context, log: log));
  }
}