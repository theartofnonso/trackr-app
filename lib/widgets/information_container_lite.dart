import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainerLite extends StatelessWidget {
  final String content;
  final Color color;

  const InformationContainerLite({super.key, required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.all(12),
      child: Text(content, style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white70)),
    );
  }
}
