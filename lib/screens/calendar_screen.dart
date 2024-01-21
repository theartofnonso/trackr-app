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

import '../dtos/routine_log_dto.dart';
import '../utils/exercise_logs_utils.dart';
import '../utils/shareables_utils.dart';
import '../widgets/buttons/text_button_widget.dart';
import '../utils/dialog_utils.dart';

GlobalKey _calendarKey = GlobalKey();

class _DateViewModel {
  final DateTime dateTime;
  final DateTime selectedDateTime;
  final bool hasLog;

  _DateViewModel({required this.dateTime, required this.selectedDateTime, required this.hasLog});
}

class CalendarScreen extends StatefulWidget {
  /// Do no make this a const as it has properties that depends on the state of this parent widget
  CalendarScreen({super.key});

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
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);
    final logsForCurrentDate = routineLogController.logsWhereDate(dateTime: _currentDate).reversed.toList();

    final dates = _generateDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: _decrementDate,
                icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentDate.formattedMonthAndYear(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      )),
                  IconButton(
                      onPressed: _onShareCalendar,
                      icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 18))
                ],
              ),
            ),
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
        _Month(dates: dates, selectedDateTime: _currentDate, onTap: _selectDate),
        const SizedBox(height: 10),
        if (logsForCurrentDate.isNotEmpty) _RoutineLogListView(logs: logsForCurrentDate),
        if (logsForCurrentDate.isEmpty)
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

  void _onShareCalendar() {
    displayBottomSheet(
        color: tealBlueDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        context: context,
        isScrollControlled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          RepaintBoundary(
              key: _calendarKey,
              child: Container(
                  color: tealBlueDark,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_currentDate.formattedMonthAndYear(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          )),
                      SharedPrefs().showCalendarDates
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: _CalendarHeader(),
                            )
                          : const SizedBox(height: 8),
                      _Month(
                          dates: _generateDates(), selectedDateTime: _currentDate, onTap: (_) {}, showSelector: false),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/trackr.png',
                          fit: BoxFit.contain,
                          height: 8, // Adjust the height as needed
                        ),
                      ),
                    ],
                  ))),
          const SizedBox(height: 10),
          CTextButton(
              onPressed: () {
                captureImage(key: _calendarKey, pixelRatio: 5);
                Navigator.of(context).pop();
              },
              label: "Share",
              buttonColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              buttonBorderColor: Colors.transparent)
        ]));
  }
}

class _CalendarHeader extends StatelessWidget {
  final List<String> daysOfWeek = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 25,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1, // for square shape
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
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

class _Date extends StatelessWidget {
  final DateTime dateTime;
  final DateTime selectedDateTime;
  final bool showSelector;
  final bool hasLog;
  final void Function(DateTime dateTime) onTap;

  const _Date(
      {required this.dateTime,
      required this.selectedDateTime,
      required this.onTap,
      required this.showSelector,
      required this.hasLog});

  Color _getBackgroundColor() {
    return hasLog ? Colors.green : tealBlueLight.withOpacity(0.5);
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
      return hasLog ? Colors.white : Colors.white70;
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
        padding: selectedDateTime.isSameDateAs(dateTime) && showSelector ? const EdgeInsets.all(1) : null,
        decoration: showSelector
            ? BoxDecoration(
                border: _getBorder(),
                borderRadius: BorderRadius.circular(5),
              )
            : null,
        child: Container(
          margin: const EdgeInsets.all(4),
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

class _Month extends StatelessWidget {
  final List<_DateViewModel?> dates;
  final DateTime selectedDateTime;
  final bool showSelector;
  final void Function(DateTime dateTime) onTap;

  const _Month({required this.dates, required this.selectedDateTime, required this.onTap, this.showSelector = true});

  @override
  Widget build(BuildContext context) {
    final datesWidgets = dates.map((date) {
      if (date == null) {
        return const SizedBox();
      } else {
        return _Date(
          dateTime: date.dateTime,
          onTap: onTap,
          selectedDateTime: selectedDateTime,
          showSelector: showSelector,
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
