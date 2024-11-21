import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquaredChips extends StatelessWidget {
  final String label;
  final Color color;

  const SquaredChips({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Text(label,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
            )),
      ],
    );
  }
}
