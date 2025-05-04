import 'package:flutter/cupertino.dart';

import '../../colors.dart';
import '../buttons/opacity_button_widget_two.dart';

class DatetimePicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final void Function(DateTime datetime) onSelect;
  final CupertinoDatePickerMode? mode;

  const DatetimePicker({super.key, this.initialDateTime, required this.onSelect, required this.mode});

  @override
  State<DatetimePicker> createState() => _DatetimePickerState();
}

class _DatetimePickerState extends State<DatetimePicker> {
  DateTime _dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoDatePicker(
              mode: widget.mode ?? CupertinoDatePickerMode.dateAndTime,
              use24hFormat: true,
              onDateTimeChanged: (DateTime value) {
                _dateTime = value;
              }),
        ),
        const SizedBox(height: 10),
        OpacityButtonWidgetTwo(
          onPressed: () => widget.onSelect(_dateTime),
          label: "Select date",
          buttonColor: vibrantGreen,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final previousDateTime = widget.initialDateTime;
    _dateTime = previousDateTime ?? DateTime.now();
  }
}
