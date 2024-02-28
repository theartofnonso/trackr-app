import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextEmptyState extends StatelessWidget {
  final String message;
  const TextEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message, style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white));
  }
}
