import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetText extends StatelessWidget {
  final String label;
  final String? string;
  final num? number;

  const SetText({super.key, required this.label, this.string, this.number});

  @override
  Widget build(BuildContext context) {

    final value = string ?? number;

    return Row(
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 10),

      ],
    );
  }
}