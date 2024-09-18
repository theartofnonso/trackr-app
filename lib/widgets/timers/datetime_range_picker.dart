import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/information_container_lite.dart';

import '../../strings/workout_log_strings.dart';
import '../buttons/opacity_button_widget.dart';
import '../buttons/solid_button_widget.dart';

class DateTimeRangePicker extends StatefulWidget {
  final void Function(DateTimeRange range) onSelectRange;

  const DateTimeRangePicker({super.key, required this.onSelectRange});

  @override
  State<DateTimeRangePicker> createState() => _DateTimeRangePickerState();
}

class _DateTimeRangePickerState extends State<DateTimeRangePicker> {
  DateTime _startDateTime = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _endDateTime = DateTime.now();

  bool _showStartDateTimeRange = false;
  bool _showEndDateTimeRange = false;

  @override
  Widget build(BuildContext context) {
    final errorMessage = _validateDate();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
              title: Text(
                "Start Time",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: SolidButtonWidget(
                  onPressed: () {
                    setState(() {
                      _showStartDateTimeRange = !_showStartDateTimeRange;
                      _showEndDateTimeRange = false;
                    });
                  },
                  buttonColor: _showStartDateTimeRange ? vibrantGreen : sapphireLighter,
                  textColor: _showStartDateTimeRange ? sapphireDark : Colors.white,
                  label: _startDateTime.formattedDayMonthTime())),
          if (_showStartDateTimeRange)
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                  use24hFormat: true,
                  initialDateTime: _startDateTime,
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _startDateTime = value;
                    });
                  }),
            ),
          ListTile(
              title: Text(
                "End Time",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: SolidButtonWidget(
                  onPressed: () {
                    setState(() {
                      _showStartDateTimeRange = false;
                      _showEndDateTimeRange = !_showEndDateTimeRange;
                    });
                  },
                  buttonColor: _showEndDateTimeRange ? vibrantGreen : sapphireLighter,
                  textColor: _showEndDateTimeRange ? sapphireDark : Colors.white,
                  label: _endDateTime.formattedDayMonthTime())),
          if (_showEndDateTimeRange)
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                  use24hFormat: true,
                  initialDateTime: _endDateTime,
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _endDateTime = value;
                    });
                  }),
            ),
          SizedBox(
            height: 90,
            child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InformationContainerLite(content: errorMessage, color: Colors.orange),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: OpacityButtonWidget(
                            onPressed: () {
                              final range = DateTimeRange(start: _startDateTime, end: _endDateTime);
                              widget.onSelectRange(range);
                            },
                            label: "Log ${_calculateDuration().hmsAnalog()} session",
                            buttonColor: vibrantGreen,
                            padding: const EdgeInsets.all(10.0)),
                      )),
          ),
        ],
      ),
    );
  }

  String? _validateDate() {
    if (_startDateTime.isAfter(_endDateTime)) {
      return edit_startdate_must_be_before_enddate;
    }

    if (_endDateTime.isBefore(_startDateTime)) {
      return edit_enddate_must_be_after_startdate;
    }

    if (_endDateTime.day > DateTime.now().day) {
      return edit_future_date_restriction;
    }

    Duration difference = _endDateTime.difference(_startDateTime);

    if (difference.inHours > 24) {
      return edit_24_hour_restriction;
    }

    return null;
  }

  Duration _calculateDuration() {
    return _endDateTime.difference(_startDateTime);
  }
}
