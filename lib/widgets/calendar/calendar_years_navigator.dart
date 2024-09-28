import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../enums/chart_period_enum.dart';

class CalendarYearsNavigator extends StatefulWidget {
  final void Function(DateTimeRange? range)? onChangedDateTimeRange;
  final ChartPeriod chartPeriod;

  const CalendarYearsNavigator({super.key, this.onChangedDateTimeRange, this.chartPeriod = ChartPeriod.month});

  @override
  State<CalendarYearsNavigator> createState() => _CalendarYearsNavigatorState();
}

class _CalendarYearsNavigatorState extends State<CalendarYearsNavigator> {
  late DateTime _currentDate;

  bool _hasLaterDate() {
    final laterDate = DateTime.now();
    int laterYear = laterDate.year;
    return laterYear > _currentDate.year;
  }

  DateTime _decrementMonth() {
    int year = _currentDate.year - 1;
    return DateTime(year);
  }

  DateTime _incrementYear() {
    int year = _currentDate.year + 1;
    return DateTime(year);
  }

  void _previousDate() {
    final onChangedDateTimeRangeFunc = widget.onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    final year = _decrementMonth();
    setState(() {
      _currentDate = year;
    });

    onChangedDateTimeRangeFunc(year.dateTimeRange());

  }

  void _nextDate() {
    final onChangedDateTimeRangeFunc = widget.onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    final year = _incrementYear();
    setState(() {
      _currentDate = year;
    });

    onChangedDateTimeRangeFunc(year.dateTimeRange());
  }

  bool _canNavigate() {
    return widget.chartPeriod == ChartPeriod.month;
  }

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
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
        Text("${_currentDate.year}",
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
