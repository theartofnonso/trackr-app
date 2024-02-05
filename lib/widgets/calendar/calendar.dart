import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../controllers/settings_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../routine/preview/routine_log_widget.dart';

GlobalKey calendarKey = GlobalKey();

class _DateViewModel {
  final DateTime dateTime;
  final DateTime selectedDateTime;
  final bool hasLog;

  _DateViewModel({required this.dateTime, required this.selectedDateTime, required this.hasLog});

  @override
  String toString() {
    return '_DateViewModel{dateTime: $dateTime, selectedDateTime: $selectedDateTime, hasLog: $hasLog}';
  }
}

class Calendar extends StatefulWidget {
  final bool readOnly;
  final DateTimeRange range;

  const Calendar({super.key, this.readOnly = false, required this.range});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _currentDate = DateTime.now();

  void _selectDate(DateTime dateTime) {
    setState(() {
      _currentDate = dateTime;
    });
  }

  List<_DateViewModel?> _generateDates() {
    final startDate = widget.range.start;
    final endDate = widget.range.end;

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

    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final logsForCurrentDate =
        (routineLogController.monthlyLogs[DateTimeRange(start: firstDayOfMonth, end: lastDayOfMonth)] ?? [])
            .map((log) => DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day));

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final hasLog = logsForCurrentDate.contains(date);
      datesInMonths.add(_DateViewModel(dateTime: date, selectedDateTime: _currentDate.dateOnly(), hasLog: hasLog));
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
        SharedPrefs().showCalendarDates
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _CalendarHeader(),
              )
            : const SizedBox(height: 8),
        _Month(dates: dates, selectedDateTime: _currentDate.dateOnly(), onTap: _selectDate, readOnly: widget.readOnly),
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
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
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
          selected: date.dateTime.isSameDateAs(selectedDateTime),
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
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
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
  final bool showSelector;
  final bool hasLog;
  final void Function(DateTime dateTime) onTap;

  const _Day(
      {required this.dateTime,
      required this.selected,
      required this.onTap,
      required this.showSelector,
      required this.hasLog});

  Color _getBackgroundColor() {
    return hasLog ? vibrantGreen : sapphireLight;
  }

  Color _getTextColor() {
    if (SharedPrefs().showCalendarDates) {
      return hasLog ? Colors.black : Colors.white70;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(dateTime),
      child: Container(
        padding: selected && showSelector ? const EdgeInsets.all(2) : null,
        decoration: showSelector
            ? BoxDecoration(
                border: selected ? Border.all(color: Colors.white70, width: 2.0) : null,
                borderRadius: BorderRadius.circular(2),
              )
            : null,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text("${dateTime.day}",
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: _getTextColor())),
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
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RoutineLogWidget(log: log, color: sapphireLight, trailing: log.duration().hmsAnalog()),
      );
    }).toList();

    return Column(children: widgets);
  }
}
