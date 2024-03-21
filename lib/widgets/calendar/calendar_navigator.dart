import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../enums/chart_period_enum.dart';

class CalendarNavigator extends StatefulWidget {
  final void Function(DateTimeRange? range)? onChangedDateTimeRange;
  final ChartPeriod chartPeriod;

  const CalendarNavigator({super.key, this.onChangedDateTimeRange, this.chartPeriod = ChartPeriod.month});

  @override
  State<CalendarNavigator> createState() => _CalendarNavigatorState();
}

class _CalendarNavigatorState extends State<CalendarNavigator> {

  late DateTime _currentDate;
  late DateTimeRange _currentDateTimeRange;

  bool _hasFormerDate() {
    final formerDate = DateTime.now();
    int formerMonth = formerDate.month;
    int formerYear = formerDate.year;
    if (formerYear == _currentDate.year) {
      return formerMonth < _currentDate.month;
    } else {
      return formerYear < _currentDate.year;
    }
  }

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
    return _currentDate.formattedMonthAndYear();
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
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 16)),
        SizedBox(
          width: 120,
          child: Text(_formattedDate(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              )),
        ),
        IconButton(
            onPressed: widget.chartPeriod == ChartPeriod.month && _hasLaterDate() ? _nextDate : null,
            icon: FaIcon(FontAwesomeIcons.arrowRightLong,
                color: _hasLaterDate() ? Colors.white : Colors.white60, size: 16)),
      ],
    );
  }
}
