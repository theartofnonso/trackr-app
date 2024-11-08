import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OpacityCircleButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final Color? buttonColor;
  final EdgeInsets? padding;
  final VisualDensity? visualDensity;

  const OpacityCircleButtonWidget(
      {super.key,
      this.onPressed,
      required this.label,
      this.buttonColor,
      this.padding,
      this.visualDensity = VisualDensity.compact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: buttonColor?.withOpacity(0.15) ?? Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Text(label,
            textAlign: TextAlign.start,
            style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: onPressed != null ? buttonColor : buttonColor?.withOpacity(0.2))),
      ),
    );
  }
}
