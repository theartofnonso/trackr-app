import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainerLite extends StatelessWidget {
  final String content;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const InformationContainerLite({super.key, required this.content, required this.color, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      padding: padding ?? const EdgeInsets.all(12),
      child: Text(content, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
    );
  }
}
