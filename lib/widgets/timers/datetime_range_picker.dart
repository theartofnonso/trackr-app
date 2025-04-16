import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/information_containers/information_container_lite.dart';

import '../../strings/datetime_range_picker_strings.dart';
import '../buttons/opacity_button_widget.dart';

class DateTimeRangePicker extends StatefulWidget {
  final DateTimeRange? initialDateTimeRange;
  final void Function(DateTimeRange range) onSelectRange;

  const DateTimeRangePicker({super.key, required this.onSelectRange, this.initialDateTimeRange});

  @override
  State<DateTimeRangePicker> createState() => _DateTimeRangePickerState();
}

class _DateTimeRangePickerState extends State<DateTimeRangePicker> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  bool _showStartDateTimeRange = false;
  bool _showEndDateTimeRange = false;

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final errorMessage = _validateDate();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
              title: Text("Start Time"),
              trailing: SizedBox(
                width: 150,
                child: OpacityButtonWidget(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    onPressed: () {
                      setState(() {
                        _showStartDateTimeRange = !_showStartDateTimeRange;
                        _showEndDateTimeRange = false;
                      });
                    },
                    buttonColor: _showStartDateTimeRange ? vibrantGreen : null,
                    label: _startDateTime.formattedDayMonthTime()),
              )),
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
              title: Text("End Time"),
              trailing: SizedBox(
                width: 150,
                child: OpacityButtonWidget(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    onPressed: () {
                      setState(() {
                        _showStartDateTimeRange = false;
                        _showEndDateTimeRange = !_showEndDateTimeRange;
                      });
                    },
                    buttonColor: _showEndDateTimeRange ? vibrantGreen : null,
                    label: _endDateTime.formattedDayMonthTime()),
              )),
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
                        height: 45,
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
      return editStartDateMustBeBeforeEndDate;
    }

    if (_endDateTime.isBefore(_startDateTime)) {
      return editEndDateMustBeAfterStartDate;
    }

    if (_endDateTime.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
      return editFutureDateRestriction;
    }

    Duration difference = _endDateTime.difference(_startDateTime);

    if (difference.inHours > 24) {
      return edit24HourRestriction;
    }

    return null;
  }

  Duration _calculateDuration() {
    return _endDateTime.difference(_startDateTime);
  }

  @override
  void initState() {
    super.initState();
    _startDateTime = widget.initialDateTimeRange?.start ?? DateTime.now().subtract(const Duration(hours: 1));
    _endDateTime = widget.initialDateTimeRange?.end ?? DateTime.now();
  }
}
