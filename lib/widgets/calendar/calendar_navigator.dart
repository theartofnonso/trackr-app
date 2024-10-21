import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

class CalendarNavigator extends StatefulWidget {
  /// Callback when the year changes, providing the date range for the year.
  final void Function(DateTimeRange yearRange) onYearChange;

  /// Callback when the month changes, providing the current month as DateTime.
  final void Function(DateTimeRange currentMonth) onMonthChange;

  /// Callback providing all weeks in the current year.
  final void Function(List<DateTimeRange> weeksInYear) onWeeksInYearChange;

  /// Callback providing all weeks in the current month.
  final void Function(List<DateTimeRange> weeksInMonth) onWeeksInMonthChange;

  /// Optional initial date to set the starting month and year.
  final DateTime? initialDate;

  const CalendarNavigator({
    super.key,
    required this.onYearChange,
    required this.onMonthChange,
    required this.onWeeksInYearChange,
    required this.onWeeksInMonthChange,
    this.initialDate,
  });

  @override
  State<CalendarNavigator> createState() => _CalendarNavigatorState();
}

class _CalendarNavigatorState extends State<CalendarNavigator> {
  late DateTime _currentDate;
  late int _currentYear;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentDate = widget.initialDate ?? DateTime(_today.year, _today.month, 1);
    _currentYear = _currentDate.year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyAll();
    });
  }

  /// Navigates to the previous month.
  void _goToPreviousMonth() {
    setState(() {
      if (_currentDate.month == 1) {
        _currentDate = DateTime(_currentDate.year - 1, 12, 1);
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
      _handleYearChange();
      _notifyAll();
    });
  }

  /// Navigates to the next month if it's not beyond the current month.
  void _goToNextMonth() {
    setState(() {
      DateTime nextMonth = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      // Prevent navigating to future months beyond today
      DateTime currentMonthStart = DateTime(_today.year, _today.month, 1);
      if (nextMonth.isAfter(currentMonthStart)) {
        // Do not navigate to future months.
        return;
      }

      if (_currentDate.month == 12) {
        _currentDate = DateTime(_currentDate.year + 1, 1, 1);
      } else {
        _currentDate = nextMonth;
      }
      _handleYearChange();
      _notifyAll();
    });
  }

  /// Handles year change and notifies via callback if the year has changed.
  void _handleYearChange() {
    if (_currentDate.year != _currentYear) {
      _currentYear = _currentDate.year;
      _notifyYearChange();
    }
  }

  /// Notifies all callbacks: year range, month range, weeks in year, weeks in month.
  void _notifyAll() {
    _notifyMonthChange();
    _notifyWeeksInYearChange();
    _notifyWeeksInMonthChange();
  }

  /// Notifies the month change via callback with the date range of the current month.
  void _notifyMonthChange() {
    DateTime startDate = _currentDate.startOfMonth();
    DateTime endDate = _currentDate.endOfMonth();
    DateTimeRange monthRange = DateTimeRange(start: startDate, end: endDate);
    widget.onMonthChange(monthRange);
  }

  /// Notifies the year change via callback with the date range of the current year.
  void _notifyYearChange() {
    DateTime startDate = DateTime(_currentYear, 1, 1);
    DateTime endDate = DateTime(_currentYear, 12, 31);
    DateTimeRange yearRange = DateTimeRange(start: startDate, end: endDate);
    widget.onYearChange(yearRange);
  }

  /// Notifies the weeks in the year via callback.
  void _notifyWeeksInYearChange() {
    List<DateTimeRange> weeks = _getWeeksInYear(_currentYear);
    widget.onWeeksInYearChange(weeks);
  }

  /// Notifies the weeks in the month via callback.
  void _notifyWeeksInMonthChange() {
    List<DateTimeRange> weeks = _getWeeksInMonth(_currentDate);
    widget.onWeeksInMonthChange(weeks);
  }

  /// Returns a list of DateTimeRange representing each week in the given year.
  List<DateTimeRange> _getWeeksInYear(int year) {
    List<DateTimeRange> weeks = [];
    DateTime firstDayOfYear = DateTime(year, 1, 1);
    // Find the first Monday of the year
    DateTime firstMonday = firstDayOfYear.weekday == DateTime.monday
        ? firstDayOfYear
        : firstDayOfYear.add(Duration(days: 8 - firstDayOfYear.weekday));

    for (DateTime weekStart = firstMonday;
    weekStart.year == year;
    weekStart = weekStart.add(const Duration(days: 7))) {
      DateTime weekEnd = weekStart.add(const Duration(days: 6));
      // Adjust weekEnd if it goes beyond the year
      if (weekEnd.year > year) {
        weekEnd = DateTime(year, 12, 31);
      }
      weeks.add(DateTimeRange(start: weekStart, end: weekEnd));
    }

    return weeks;
  }

  /// Returns a list of DateTimeRange representing each week in the given month.
  List<DateTimeRange> _getWeeksInMonth(DateTime monthDate) {
    List<DateTimeRange> weeks = [];
    DateTime firstDayOfMonth = monthDate.startOfMonth();
    DateTime lastDayOfMonth = monthDate.endOfMonth();

    // Find the first Monday on or before the first day of the month
    DateTime firstMonday = firstDayOfMonth.weekday == DateTime.monday
        ? firstDayOfMonth
        : firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - DateTime.monday));

    // Iterate through each week
    for (DateTime weekStart = firstMonday;
    weekStart.isBefore(lastDayOfMonth);
    weekStart = weekStart.add(const Duration(days: 7))) {
      DateTime weekEnd = weekStart.add(const Duration(days: 6));

      // Adjust weekStart and weekEnd to be within the month
      DateTime actualStart = weekStart.isBefore(firstDayOfMonth) ? firstDayOfMonth : weekStart;
      DateTime actualEnd = weekEnd.isAfter(lastDayOfMonth) ? lastDayOfMonth : weekEnd;

      weeks.add(DateTimeRange(start: actualStart, end: actualEnd));
    }

    return weeks;
  }

  /// Formats the month and year for display.
  String _formattedMonthYear() {
    return "${_monthName(_currentDate.month)} ${_currentDate.year}";
  }

  /// Returns the month name based on the month number.
  String _monthName(int monthNumber) {
    const List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime currentMonthStart = DateTime(today.year, today.month, 1);
    bool canNavigateNext = !_currentDate.monthlyStartDate().isAtSameMomentAs(currentMonthStart);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: _goToPreviousMonth,
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 16)),
        Text(_formattedMonthYear(),
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
