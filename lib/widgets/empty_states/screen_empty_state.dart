import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenEmptyState extends StatelessWidget {
  final String message;
  const ScreenEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }
}
