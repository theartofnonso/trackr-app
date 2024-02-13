import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../enums/chart_period_enum.dart';

class CalendarNavigator extends StatelessWidget {
  final DateTime currentDate;
  final void Function(DateTimeRange? range)? onChangedDateTimeRange;
  final void Function(DateTime)? onSelectedDate;
  final ChartPeriod chartPeriod;

  const CalendarNavigator(
      {super.key,
      required this.currentDate,
      this.onChangedDateTimeRange,
      this.onSelectedDate,
      this.chartPeriod = ChartPeriod.month});

  bool _hasLaterDate() {
    final laterDate = DateTime.now();
    int laterMonth = laterDate.month;
    int laterYear = laterDate.year;
    if (laterYear == currentDate.year) {
      return laterMonth > currentDate.month;
    } else if (laterYear > currentDate.year) {
      return true;
    } else {
      return false;
    }
  }

  DateTimeRange _decrementMonth() {
    int month = currentDate.month - 1;
    int year = currentDate.year;

    /// We need to go to previous year
    if (month == 0) {
      month = 12;
      year = year - 1;
    }

    final currentMonth = DateTime(year, month);

    return DateTimeRange(start: currentMonth, end: DateTime(currentMonth.year, currentMonth.month + 1, 0));
  }

  DateTimeRange _decrementWeek() {
    DateTime previousWeek = currentDate.subtract(const Duration(days: 7));
    return DateTimeRange(
        start: previousWeek.dateOnly(), end: DateTime(currentDate.year, currentDate.month, currentDate.day));
  }

  void previousDate() {
    final onChangedDateTimeRangeFunc = onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    if (chartPeriod == ChartPeriod.month) {
      final range = _decrementMonth();
      onChangedDateTimeRangeFunc(range);
    } else if (chartPeriod == ChartPeriod.week) {
      final range = _decrementWeek();
      onChangedDateTimeRangeFunc(range);
    }
  }

  DateTimeRange? _incrementMonth() {
    DateTimeRange? dateTimeRange;

    if (_hasLaterDate()) {
      int month = currentDate.month + 1;
      int year = currentDate.year;

      /// We need to go to next year
      if (month == 12) {
        month = 0;
        year = year + 1;
      }

      final currentMonth = DateTime(year, month);

      dateTimeRange = DateTimeRange(start: currentMonth, end: DateTime(currentMonth.year, currentMonth.month + 1, 0));
    }

    return dateTimeRange;
  }

  DateTimeRange? _incrementWeek() {
    DateTimeRange? dateTimeRange;

    if (_hasLaterDate()) {
      DateTime nextWeek = currentDate.add(const Duration(days: 7));

      dateTimeRange = DateTimeRange(
          start: DateTime(currentDate.year, currentDate.month, currentDate.day), end: nextWeek.dateOnly());
    }

    return dateTimeRange;
  }

  void nextDate() {
    final onChangedDateTimeRangeFunc = onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    if (chartPeriod == ChartPeriod.month) {
      final range = _incrementMonth();
      onChangedDateTimeRangeFunc(range);
    } else if (chartPeriod == ChartPeriod.week) {
      final range = _incrementWeek();
      onChangedDateTimeRangeFunc(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: previousDate, icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 16)),
        SizedBox(
          width: 125,
          child: Text(currentDate.formattedMonthAndYear(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              )),
        ),
        IconButton(
            onPressed: _hasLaterDate() ? nextDate : null,
            icon: FaIcon(FontAwesomeIcons.arrowRightLong,
                color: _hasLaterDate() ? Colors.white : Colors.white60, size: 16)),
      ],
    );
  }
}
