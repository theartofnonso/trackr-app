import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightedSetHeader extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;

  const WeightedSetHeader({super.key, required this.firstLabel, required this.secondLabel});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(30),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
            },
      children: <TableRow>[
        TableRow(children: [
          Text("SET",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text(firstLabel,
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          Text(secondLabel,
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
        ]),
      ],
    );
  }
}
