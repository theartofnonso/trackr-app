import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

class _DateViewModel {
  final DateTime dateTime;
  final DateTime selectedDateTime;
  final bool hasRoutineLog;

  _DateViewModel({required this.dateTime, required this.selectedDateTime, this.hasRoutineLog = false});
}

const int _kWeekOrigin = 1000; // middle of the pager
const int _kMonthOrigin = 1000;

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    this.onSelectDate,
    required this.dateTime,
  });

  final void Function(DateTime dateTime)? onSelectDate;
  final DateTime dateTime;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with SingleTickerProviderStateMixin {
  late DateTime _selected;
  late DateTime _focused;
  late final PageController _weekCtl;
  late final PageController _monthCtl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.dateTime.withoutTime();
    _focused = _selected;
    _weekCtl = PageController(initialPage: _kWeekOrigin);
    _monthCtl = PageController(initialPage: _kMonthOrigin);
  }

  // ───────────────────────────  Helpers  ────────────────────────────

  DateTime _mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

  DateTime _weekByIndex(int pageIndex) =>
      _mondayOf(widget.dateTime).add(Duration(days: (pageIndex - _kWeekOrigin) * 7));

  DateTime _monthByIndex(int pageIndex) =>
      DateTime(widget.dateTime.year, widget.dateTime.month + (pageIndex - _kMonthOrigin), 1);

  void _onDateTap(DateTime d) {
    setState(() => _selected = d);
    widget.onSelectDate?.call(d);
  }

  void _toggleView() => setState(() => _expanded = !_expanded);

  // ───────────────────────────  Build  ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Column(
      children: [
        _CalendarTitleHeader(
          date: _focused,
          isExpanded: _expanded,
          onToggle: _toggleView,
          isDarkMode: isDark,
        ),
        const SizedBox(height: 10),
        const _CalendarHeader(),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double rowHeight = 54.0; // estimated row height
              final int rowCount = _expanded ? 6 : 1;
              final double height = rowHeight * rowCount;

              return SizedBox(
                height: height,
                child: _expanded
                    ? _buildMonthPager(isDark)
                    : _buildWeekPager(isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  // Week pager  ──────────────────────────────────────────────────────

  Widget _buildWeekPager(bool isDark) {
    return PageView.builder(
      controller: _weekCtl,
      onPageChanged: (page) => setState(() => _focused = _weekByIndex(page)),
      itemBuilder: (_, page) {
        final monday = _weekByIndex(page);
        final days = List.generate(7, (i) => monday.add(Duration(days: i)));
        final logs = context.read<ExerciseAndRoutineController>().logs;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: 7,
          itemBuilder: (_, i) {
            final d = days[i];
            final has = logs.any((l) => l.createdAt.isSameDayMonthYear(d));
            return _Day(
              dateTime: d,
              selected: d.isSameDayMonthYear(_selected),
              currentDate: d.isSameDayMonthYear(DateTime.now()),
              hasRoutineLog: has,
              onTap: _onDateTap,
              isDarkMode: isDark,
            );
          },
        );
      },
    );
  }

  // Month pager  ─────────────────────────────────────────────────────

  Widget _buildMonthPager(bool isDark) {
    return PageView.builder(
      controller: _monthCtl,
      onPageChanged: (page) => setState(() => _focused = _monthByIndex(page)),
      itemBuilder: (_, page) {
        final monthStart = _monthByIndex(page);
        final grid = _generateMonthDates(monthStart);
        return _Month(
          dates: grid,
          selectedDateTime: _selected,
          onTap: _onDateTap,
          isDarkMode: isDark,
        );
      },
    );
  }

  // Utilities to build month grid  ───────────────────────────────────

  List<_DateViewModel?> _generateMonthDates(DateTime monthStart) {
    final first = DateTime(monthStart.year, monthStart.month, 1);
    final last = DateTime(monthStart.year, monthStart.month + 1, 0);
    final logs = context
        .read<ExerciseAndRoutineController>()
        .logs
        .where((l) => l.createdAt.isBetweenInclusive(from: first, to: last));

    final List<_DateViewModel?> out = [];
    for (int i = 1; i < first.weekday; i++) {
      out.add(null);
    }
    for (int d = 1; d <= last.day; d++) {
      final date = DateTime(monthStart.year, monthStart.month, d);
      final has = logs.any((l) => l.createdAt.isSameDayMonthYear(date));
      out.add(_DateViewModel(dateTime: date, selectedDateTime: _selected, hasRoutineLog: has));
    }
    while (out.length % 7 != 0) {
      out.add(null);
    }
    return out;
  }
}

class _CalendarTitleHeader extends StatelessWidget {
  final DateTime date;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool isDarkMode;

  const _CalendarTitleHeader({
    required this.date,
    required this.isExpanded,
    required this.onToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(date),
            style: GoogleFonts.ubuntu(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return SizedBox(
      height: 25,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 7,
        itemBuilder: (_, index) => Text(
          ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.white70 : Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Month extends StatelessWidget {
  final List<_DateViewModel?> dates;
  final DateTime selectedDateTime;
  final void Function(DateTime dateTime) onTap;
  final bool isDarkMode;

  const _Month({required this.dates, required this.selectedDateTime, required this.onTap, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: dates.length,
      itemBuilder: (_, index) => dates[index] == null
          ? const SizedBox()
          : _Day(
              dateTime: dates[index]!.dateTime,
              selected: dates[index]!.dateTime.isSameDayMonthYear(selectedDateTime),
              currentDate: dates[index]!.dateTime.isSameDayMonthAndYear(DateTime.now()),
              hasRoutineLog: dates[index]!.hasRoutineLog,
              onTap: onTap,
              isDarkMode: isDarkMode,
            ),
    );
  }
}

class _Day extends StatelessWidget {
  final DateTime dateTime;
  final bool selected;
  final bool hasRoutineLog;
  final bool currentDate;
  final void Function(DateTime dateTime) onTap;
  final bool isDarkMode;

  const _Day({
    required this.dateTime,
    required this.selected,
    required this.currentDate,
    required this.onTap,
    this.hasRoutineLog = false,
    required this.isDarkMode,
  });

  Color _getBackgroundColor() => hasRoutineLog
      ? (isDarkMode ? vibrantGreen.withValues(alpha: 0.1) : vibrantGreen)
      : (isDarkMode ? sapphireDark80.withValues(alpha: 0.5) : Colors.grey.shade200);

  Color _getTextColor() =>
      hasRoutineLog ? (isDarkMode ? vibrantGreen : Colors.black) : (isDarkMode ? Colors.white : Colors.black);

  Border? _dateBorder() {
    if (selected) return Border.all(color: Colors.blueGrey, width: 2);
    if (currentDate) return Border.all(color: Colors.grey, width: 2);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(dateTime),
      child: Container(
        padding: selected ? const EdgeInsets.all(2) : null,
        decoration: BoxDecoration(border: _dateBorder(), borderRadius: BorderRadius.circular(2)),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: _getBackgroundColor(), borderRadius: BorderRadius.circular(2)),
          child: Center(
            child: Text(
              "${dateTime.day}",
              style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.bold, color: _getTextColor()),
            ),
          ),
        ),
      ),
    );
  }
}
