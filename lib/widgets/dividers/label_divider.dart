import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelDivider extends StatelessWidget {
  final String label;
  final double fontSize;
  final bool shouldCapitalise;
  final Color labelColor;
  final Color dividerColor;
  final bool leftToRight;
  const LabelDivider({super.key, required this.label, this.fontSize = 10, this.shouldCapitalise = false, required this.labelColor, required this.dividerColor, this.leftToRight = true});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      leftToRight ? Text(
        shouldCapitalise ? label.toUpperCase() : label,
        style: GoogleFonts.ubuntu(color: labelColor, fontWeight: FontWeight.w700, fontSize: fontSize),
      ) : SizedBox.shrink(),
      Expanded(
        child: Container(
          height: 0.8, // height of the divider
          width: double.infinity, // width of the divider (line thickness)
          color: dividerColor, // color of the divider
          margin: const EdgeInsets.symmetric(horizontal: 10), // add space around the divider
        ),
      ),
      !leftToRight ? Text(
        shouldCapitalise ? label.toUpperCase() : label,
        style: GoogleFonts.ubuntu(color: labelColor, fontWeight: FontWeight.w700, fontSize: fontSize),
      ) : SizedBox.shrink()
    ]);
  }
}
