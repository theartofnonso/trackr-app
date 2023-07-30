import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/DateTimeEntry.dart';
import 'package:tracker_app/providers/datetime_entry_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/pulse_animation_container.dart';

import '../utils/snackbar_utils.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month);

  void _goToPreviousMonth({required DateTimeEntry? initialDateTimeEntry}) {
    final initialTemporalDateTime = initialDateTimeEntry?.createdAt;
    if (initialTemporalDateTime != null) {
      final initialDateTime = DateTime(
          initialTemporalDateTime.getDateTimeInUtc().year,
          initialTemporalDateTime.getDateTimeInUtc().month);
      if (initialDateTime.isBefore(_currentDate)) {
        setState(() {
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
        });
      }
    }
  }

  void _goToNextMonth() {
    final now = DateTime(DateTime.now().year, DateTime.now().month);
    if (_currentDate.isBefore(now)) {
      setState(() {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DateTimeEntryProvider>(
      builder: (_, dateTimeEntryProvider, __) {
        return Container(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(32, 35, 37, 0.3),
            borderRadius: BorderRadius.circular(
                5), // Adjust the radius as per your requirement
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () => _goToPreviousMonth(
                        initialDateTimeEntry:
                            dateTimeEntryProvider.dateTimeEntries.first),
                    splashColor: Colors.transparent,
                    child: const Icon(
                      Icons.arrow_circle_left_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(_currentDate.formattedMonthAndYear(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const Spacer(),
                  InkWell(
                    onTap: _goToNextMonth,
                    splashColor: Colors.transparent,
                    child: const Icon(
                      Icons.arrow_circle_right_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              CalendarHeader(),
              CalendarDates(
                  dateTimeEntries: dateTimeEntryProvider.dateTimeEntries,
                  currentDate: _currentDate)
            ],
          ),
        );
      },
    );
  }
}

class CalendarHeader extends StatelessWidget {
  CalendarHeader({super.key});

  final List<String> daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"];

  List<Widget> _getHeaders() {
    return daysOfWeek.map((day) => HeaderWidget(label: day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [..._getHeaders()],
    );
  }
}

class CalendarDates extends StatelessWidget {
  final List<DateTimeEntry> dateTimeEntries;
  final DateTime currentDate;

  const CalendarDates(
      {super.key, required this.dateTimeEntries, required this.currentDate});

  List<Widget> _datesToColumns({required DateTime currentDateTime}) {
    int year = currentDate.year;
    int month = currentDate.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 1);

    List<Widget> datesInMonths = [];

    // Add padding to start of month
    final isFirstDayNotMonday = firstDayOfMonth.weekday > 1;
    if (isFirstDayNotMonday) {
      final precedingDays = firstDayOfMonth.weekday - 1;
      final emptyWidgets =
          List.filled(precedingDays, const OtherDateWidget(label: ""));
      datesInMonths.addAll(emptyWidgets);
    }

    // Add remainder dates
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateTimeEntry = dateTimeEntries.firstWhereOrNull((dateTimeEntry) =>
          dateTimeEntry.createdAt!
              .getDateTimeInUtc()
              .isSameDateAs(other: date));
      datesInMonths.add(OtherDateWidget(
          label: date.day.toString(),
          dateTime: date,
          dateTimeEntry: dateTimeEntry));
    }

    // Add padding to end of month
    final succeedingDays = 35 - lastDayOfMonth.day;
    final emptyWidgets = List.filled(
        succeedingDays,
        const OtherDateWidget(
          label: "",
          dateTime: null,
        ));
    datesInMonths.addAll(emptyWidgets);

    return datesInMonths;
  }

  List<Widget> _dateToRows({required DateTime currentDateTime}) {
    List<Widget> widgets = [];
    final dates = _datesToColumns(currentDateTime: currentDateTime);
    int iterationCount = 6;
    int numbersPerIteration = 7;

    for (int i = 0; i < iterationCount; i++) {
      int startIndex = i * numbersPerIteration;
      int endIndex = (i + 1) * numbersPerIteration;

      if (endIndex > dates.length) {
        endIndex = dates.length;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [...dates.sublist(startIndex, endIndex)],
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [..._dateToRows(currentDateTime: currentDate)],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String label;

  const HeaderWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }
}

mixin DateTimeEntryMixin {
  void addNewDateTimeEntry(
      {required BuildContext context, required DateTime? dateTime}) async {
    if (dateTime != null) {
      await Provider.of<DateTimeEntryProvider>(context, listen: false)
          .addDateTimeEntry(dateTime: dateTime);
      if (context.mounted) {
        showSnackbar(
            context: context,
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Colors.black,
            ),
            message: 'Date added successfully');
      }
    }
  }

  void removeDateTimeEntry(
      {required BuildContext context, required DateTimeEntry? entry}) async {
    if (entry != null) {
      await Provider.of<DateTimeEntryProvider>(context, listen: false)
          .removeDateTimeEntry(entryToRemove: entry);
      if (context.mounted) {
        showSnackbar(
            context: context,
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Colors.black,
            ),
            message: 'Date removed successfully');
      }
    }
  }

  void onSelectDateTimeEntry(
      {required BuildContext context, required DateTimeEntry? entry}) async {
    if (entry != null) {
      Provider.of<DateTimeEntryProvider>(context, listen: false)
          .onSelectDateEntry(entry: entry);
    }
  }
}

class OtherDateWidget extends StatelessWidget with DateTimeEntryMixin {
  final String label;
  final DateTime? dateTime;
  final DateTimeEntry? dateTimeEntry;

  const OtherDateWidget(
      {super.key, required this.label, this.dateTime, this.dateTimeEntry});

  @override
  Widget build(BuildContext context) {
    final isCurrentDay = dateTime?.isNow() ?? false;

    return InkWell(
      onDoubleTap: () {
        if (dateTimeEntry == null) {
          addNewDateTimeEntry(context: context, dateTime: dateTime);
        } else {
          removeDateTimeEntry(context: context, entry: dateTimeEntry);
        }
      },
      onTap: () =>
          onSelectDateTimeEntry(context: context, entry: dateTimeEntry),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: isCurrentDay
            ? CurrentDateWidget(
                label: label,
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: dateTimeEntry != null
                      ? Border.all(
                          color: Colors.grey, // Set the border color here
                          width: 1.0, // Set the border width
                        )
                      : null,
                  borderRadius: BorderRadius.circular(
                      5), // Adjust the radius as per your requirement
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: Text(label,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: dateTimeEntry != null
                                ? Colors.grey
                                : Colors.white)),
                  ),
                ),
              ),
      ),
    );
  }
}

class CurrentDateWidget extends StatelessWidget {
  final String label;

  const CurrentDateWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return PulsatingWidget(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
              5), // Adjust the radius as per your requirement
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ),
      ),
    );
  }
}
