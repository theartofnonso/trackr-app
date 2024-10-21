import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarNavigator extends StatefulWidget {
  /// Callback when the year changes, providing the date range for the year.
  final void Function(DateTimeRange yearRange) onYearChange;

  /// Callback when the month changes, providing the current month as DateTime.
  final void Function(DateTimeRange currentMonth) onMonthChange;

  /// Optional initial date to set the starting month and year.
  final DateTime? initialDate;

  const CalendarNavigator({
    super.key,
    required this.onYearChange,
    required this.onMonthChange,
    this.initialDate,
  });

  @override
  State<CalendarNavigator> createState() => _CalendarNavigatorState();
}

class _CalendarNavigatorState extends State<CalendarNavigator> {
  late DateTime _currentDate;
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    // Initialize _currentDate to initialDate or today's date
    _currentDate = widget.initialDate ?? DateTime.now();
    _currentYear = _currentDate.year;
    // Notify initial callbacks after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyMonthChange();
      _notifyYearChange();
    });
  }

  /// Navigates to the previous month. If January, moves to December of the previous year.
  void _goToPreviousMonth() {
    setState(() {
      if (_currentDate.month == 1) {
        _currentDate = DateTime(_currentDate.year - 1, 12, 1);
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
      _handleYearChange();
      _notifyMonthChange();
    });
  }

  /// Navigates to the next month. If December, moves to January of the next year.
  void _goToNextMonth() {
    setState(() {
      if (_currentDate.month == 12) {
        _currentDate = DateTime(_currentDate.year + 1, 1, 1);
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      }
      _handleYearChange();
      _notifyMonthChange();
    });
  }

  /// Handles year change and notifies via callback if the year has changed.
  void _handleYearChange() {
    if (_currentDate.year != _currentYear) {
      _currentYear = _currentDate.year;
      _notifyYearChange();
    }
  }

  /// Notifies the month change via callback with the date range of the current month.
  void _notifyMonthChange() {
    DateTime startDate = DateTime(_currentDate.year, _currentDate.month, 1);
    DateTime endDate = DateTime(_currentDate.year, _currentDate.month + 1, 0);
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

  /// Formats the month and year for display.
  String _formattedMonthYear() {
    return "${_monthName(_currentDate.month)} ${_currentDate.year}";
  }

  /// Returns the month name based on the month number.
  String _monthName(int monthNumber) {
    const List<String> monthNames = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return monthNames[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: _goToPreviousMonth,
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong,
                color: Colors.white, size: 16)),
        Text(_formattedMonthYear(),
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            )),
        IconButton(
            onPressed: _goToNextMonth,
            icon: const FaIcon(FontAwesomeIcons.arrowRightLong,
                color: Colors.white, size: 16)),
      ],
    );
  }
}
