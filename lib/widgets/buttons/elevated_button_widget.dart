import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CElevatedButtonWidget extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final GoogleFonts.lato? textStyle;

  const CElevatedButtonWidget(
      {super.key, required this.onPressed, required this.label, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey.shade100)),
      onPressed: onPressed,
      child: Text(
        label,
        style: textStyle ??
            GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}
