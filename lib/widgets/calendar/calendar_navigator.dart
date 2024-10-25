import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

class CalendarNavigator extends StatefulWidget {
  /// Callback when the month changes, providing the current month as DateTime.
  final void Function(DateTimeRange currentMonth) onMonthChange;

  const CalendarNavigator({super.key, required this.onMonthChange});

  @override
  State<CalendarNavigator> createState() => _CalendarNavigatorState();
}

class _CalendarNavigatorState extends State<CalendarNavigator> {
  late DateTime _currentDate = DateTime.now();
  final DateTime _today = DateTime.now();

  /// Navigates to the previous month.
  void _goToPreviousMonth() {
    setState(() {
      if (_currentDate.month != 1) {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
    });
    _notifyMonthChange(datetime: _currentDate);
  }

  /// Navigates to the next month if it's not beyond the current month.
  void _goToNextMonth() {
    setState(() {
      DateTime nextMonth = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      // Prevent navigating to future months beyond today
      DateTime currentMonthStart = DateTime(_today.year, _today.month, 1);
      if (!nextMonth.isAfter(currentMonthStart)) {
        // Do not navigate to future months.
        if (_currentDate.month == 12) {
          _currentDate = DateTime(_currentDate.year + 1, 1, 1);
        } else {
          _currentDate = nextMonth;
        }
      }
    });
    _notifyMonthChange(datetime: _currentDate);
  }

  /// Notifies the month change via callback with the date range of the current month.
  void _notifyMonthChange({required DateTime datetime}) {
    DateTime startDate = DateTime(datetime.year, datetime.month, 1);
    DateTime endDate = DateTime(datetime.year, datetime.month + 1, 0);
    DateTimeRange monthRange = DateTimeRange(start: startDate, end: endDate);
    widget.onMonthChange(monthRange);
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime currentMonthStart = DateTime(today.year, today.month, 1);
    bool canNavigateNext = !_currentDate.monthlyStartDate().isAtSameMomentAs(currentMonthStart);

    bool canNavigatePrevious = _currentDate.month != 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: canNavigatePrevious ? _goToPreviousMonth : null,
            icon: FaIcon(FontAwesomeIcons.arrowLeftLong,
                color: canNavigatePrevious ? Colors.white : Colors.white70, size: 16)),
        Text(_currentDate.formattedMonthAndYear(),
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            )),
        IconButton(
            onPressed: canNavigateNext ? _goToNextMonth : null,
            icon: FaIcon(FontAwesomeIcons.arrowRightLong,
                color: canNavigateNext ? Colors.white : Colors.white70, size: 16)),
      ],
    );
  }
}
