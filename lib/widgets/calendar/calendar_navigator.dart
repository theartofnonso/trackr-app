import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

class CalendarNavigator extends StatefulWidget {
  final void Function(DateTimeRange range)? onChangedDateTimeRange;
  final void Function(DateTime)? onSelectedDate;

  const CalendarNavigator({super.key, this.onChangedDateTimeRange, this.onSelectedDate});

  @override
  State<CalendarNavigator> createState() => _CalendarNavigatorState();
}

class _CalendarNavigatorState extends State<CalendarNavigator> {
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

  DateTime _currentMonth(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.isSameDateAs(DateTime(now.year, now.month))) {
      return DateTime(dateTime.year, dateTime.month, DateTime.now().day);
    }
    return dateTime;
  }

  void _decrementDate() {
    int month = _currentDate.month - 1;
    int year = _currentDate.year;

    /// We need to go to previous year
    if (month == 0) {
      month = 12;
      year = year - 1;
    }

    final currentMonth = DateTime(year, month);

    setState(() {
      _currentDate = _currentMonth(currentMonth);
    });

    final onChangedDateTimeRange = widget.onChangedDateTimeRange;

    if (onChangedDateTimeRange != null) {
      onChangedDateTimeRange(DateTimeRange(start: currentMonth, end: DateTime(currentMonth.year, currentMonth.month + 1, 0)));
    }
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

      final currentMonth = DateTime(year, month);

      setState(() {
        _currentDate = _currentMonth(currentMonth);
      });

      final onChangedDateTimeRange = widget.onChangedDateTimeRange;
      if (onChangedDateTimeRange != null) {
        onChangedDateTimeRange(DateTimeRange(start: DateTime(year, month, 1), end: DateTime(year, month + 1, 0)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: _decrementDate,
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 16)),
        SizedBox(
          width: 125,
          child: Text(_currentDate.formattedMonthAndYear(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              )),
        ),
        IconButton(
            onPressed: _hasLaterDate() ? _incrementDate : null,
            icon: FaIcon(FontAwesomeIcons.arrowRightLong,
                color: _hasLaterDate() ? Colors.white : Colors.white60, size: 16)),
      ],
    );
  }
}
