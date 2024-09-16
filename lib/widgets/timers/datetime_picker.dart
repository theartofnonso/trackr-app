import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../buttons/text_button_widget.dart';

class DatetimePicker extends StatefulWidget {
  final void Function(DateTime datetime) onSelect;

  const DatetimePicker({super.key, required this.onSelect});

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
          child: CupertinoDatePicker(use24hFormat: true, onDateTimeChanged: (DateTime value) {
            _dateTime = value;
          }),
        ),
        const SizedBox(height: 10),
        CTextButton(
            onPressed: () {
              widget.onSelect(_dateTime);
            },
            label: "Select Date",
            buttonColor: Colors.transparent,
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }
}
