import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../enums/chart_period_enum.dart';

class CalendarNavigator extends StatelessWidget {
  final DateTimeRange dateTimeRange;
  final void Function(DateTimeRange? range)? onChangedDateTimeRange;
  final ChartPeriod chartPeriod;

  const CalendarNavigator(
      {super.key, required this.dateTimeRange, this.onChangedDateTimeRange, this.chartPeriod = ChartPeriod.month});

  bool _hasLaterDate() {
    final laterDate = DateTime.now();
    int laterMonth = laterDate.month;
    int laterYear = laterDate.year;
    if (laterYear == currentDate.year) {
      return laterMonth > currentDate.month;
    } else {
      return laterYear > currentDate.year;
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

  void previousDate() {
    final onChangedDateTimeRangeFunc = onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    if (chartPeriod == ChartPeriod.month) {
      final range = _decrementMonth();
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

  void nextDate() {
    final onChangedDateTimeRangeFunc = onChangedDateTimeRange;
    if (onChangedDateTimeRangeFunc == null) return;

    if (chartPeriod == ChartPeriod.month) {
      final range = _incrementMonth();
      onChangedDateTimeRangeFunc(range);
    }
  }

  String _formattedDate() {
    if (chartPeriod == ChartPeriod.month) {
      return currentDate.formattedMonthAndYear();
    } else {
      String formattedStartDate = dateTimeRange.start.abbreviatedMonthAndYear();
      String formattedEndDate = dateTimeRange.end.abbreviatedMonthAndYear();
      return "$formattedStartDate - $formattedEndDate";
    }
  }

  DateTime get currentDate => dateTimeRange.end;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: chartPeriod == ChartPeriod.month ? previousDate : null,
            icon: FaIcon(FontAwesomeIcons.arrowLeftLong,
                color: chartPeriod == ChartPeriod.month ? Colors.white : Colors.white60, size: 16)),
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
            onPressed: chartPeriod == ChartPeriod.month && _hasLaterDate() ? nextDate : null,
            icon: FaIcon(FontAwesomeIcons.arrowRightLong,
                color: _hasLaterDate() ? Colors.white : Colors.white60, size: 16)),
      ],
    );
  }
}
