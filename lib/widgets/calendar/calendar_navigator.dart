import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../utils/date_utils.dart';

class CalendarNavigator extends StatefulWidget {
  final bool enabled;

  /// Callback when the month changes, providing the current month as DateTime.
  final void Function(DateTimeRange currentMonth) onMonthChange;

  const CalendarNavigator({super.key, required this.onMonthChange, this.enabled = true});

  @override
  State<CalendarNavigator> createState() => _CalendarNavigatorState();
}

class _CalendarNavigatorState extends State<CalendarNavigator> {
  late DateTime _currentDate = DateTime.now();
  final DateTime _today = DateTime.now();

  /// Navigates to the previous month.
  void _goToPreviousMonth() {
    final dateRange = theLastYearDateTimeRange();

    final startDate = dateRange.start;
    setState(() {
      if (startDate.isBefore(_currentDate)) {
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
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    DateTime today = DateTime.now();
    DateTime currentMonthStart = DateTime(today.year, today.month, 1);
    bool canNavigateNext = !_currentDate.monthlyStartDate().isAtSameMomentAs(currentMonthStart);

    final dateRange = theLastYearDateTimeRange();
    final startDate = dateRange.start;
    bool canNavigatePrevious = startDate.isBefore(_currentDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            onPressed: canNavigatePrevious && widget.enabled ? _goToPreviousMonth : null,
            icon: FaIcon(FontAwesomeIcons.arrowLeftLong,
                color: _getArrowIconColour(isDarkMode: isDarkMode, canNavigate: canNavigatePrevious && widget.enabled),
                size: 16)),
        Text(
            widget.enabled
                ? _currentDate.formattedMonthAndYear().toUpperCase()
                : "Trends for the past year".toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        IconButton(
            onPressed: canNavigateNext && widget.enabled ? _goToNextMonth : null,
            icon: FaIcon(FontAwesomeIcons.arrowRightLong,
                color: _getArrowIconColour(isDarkMode: isDarkMode, canNavigate: canNavigateNext && widget.enabled),
                size: 16)),
      ],
    );
  }

  Color _getArrowIconColour({required bool isDarkMode, required bool canNavigate}) {
    if (isDarkMode) {
      return canNavigate ? Colors.white : Colors.white30;
    }
    return canNavigate ? Colors.black : Colors.grey.shade300;
  }
}
