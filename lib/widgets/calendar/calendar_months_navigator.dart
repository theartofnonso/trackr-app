import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../enums/chart_period_enum.dart';

class CalendarMonthsNavigator extends StatefulWidget {
  final void Function(DateTimeRange? range)? onChangedDateTimeRange;
  final ChartPeriod chartPeriod;

  const CalendarMonthsNavigator({super.key, this.onChangedDateTimeRange, this.chartPeriod = ChartPeriod.month});

  @override
  State<CalendarMonthsNavigator> createState() => _CalendarMonthsNavigatorState();
}

class _CalendarMonthsNavigatorState extends State<CalendarMonthsNavigator> {
  late DateTime _currentDate;
  late DateTimeRange _currentDateTimeRange;

  bool _hasLaterDate() {
    final laterDate = DateTime.now();
    int laterMonth = laterDate.month;
    int laterYear = laterDate.year;
    if (laterYear == _currentDate.year) {
      return laterMonth > _currentDate.month;
    } else {
      return laterYear > _currentDate.year;
    }
  }

  DateTimeRange _decrementMonth() {
    int month = _currentDate.month - 1;
    int year = _currentDate.year;

    /// We need to go to previous year
    if (month == 0) {
      month = 12;
      year = year - 1;
    }

    final currentMonth = DateTime(year, month);

    return DateTimeRange(start: currentMonth, end: DateTime(currentMonth.year, currentMonth.month + 1, 0));
  }

  void _previousDate() {
    final onChangedDateTimeRangeFunc = widget.onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    if (widget.chartPeriod == ChartPeriod.month) {
      final range = _decrementMonth();
      setState(() {
        _currentDateTimeRange = range;
        _currentDate = _currentDateTimeRange.end;
      });
      onChangedDateTimeRangeFunc(range);
    }
  }

  DateTimeRange _incrementMonth() {
    int month = _currentDate.month + 1;
    int year = _currentDate.year;

    /// We need to go to next year
    if (month == 12) {
      month = 0;
      year = year + 1;
    }

    final currentMonth = DateTime(year, month);

    DateTimeRange dateTimeRange =
        DateTimeRange(start: currentMonth, end: DateTime(currentMonth.year, currentMonth.month + 1, 0));

    return dateTimeRange;
  }

  void _nextDate() {
    final onChangedDateTimeRangeFunc = widget.onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    if (widget.chartPeriod == ChartPeriod.month) {
      final range = _incrementMonth();
      setState(() {
        _currentDateTimeRange = range;
        _currentDate = _currentDateTimeRange.end;
      });
      onChangedDateTimeRangeFunc(range);
    }
  }

  String _formattedDate() {
    final now = DateTime.now();
    return switch (widget.chartPeriod) {
      ChartPeriod.month => _currentDate.abbreviatedMonthWithYear(),
      ChartPeriod.threeMonths => "${now.past90Days().abbreviatedMonthAndYear()} - today",
      ChartPeriod.sixMonths => "${now.past180Days().abbreviatedMonthAndYear()} - today",
    };
  }

  bool _canNavigate() {
    return widget.chartPeriod == ChartPeriod.month;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = now;
    _currentDateTimeRange = now.dateTimeRange();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: widget.chartPeriod == ChartPeriod.month ? _previousDate : null,
            icon: FaIcon(FontAwesomeIcons.arrowLeftLong,
                color: _canNavigate() ? Colors.white : Colors.white60, size: 16)),
        Text(_formattedDate(),
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            )),
        IconButton(
            onPressed: widget.chartPeriod == ChartPeriod.month && _hasLaterDate() ? _nextDate : null,
            icon: FaIcon(FontAwesomeIcons.arrowRightLong,
                color: _hasLaterDate() && _canNavigate() ? Colors.white : Colors.white60, size: 16)),
      ],
    );
  }
}
