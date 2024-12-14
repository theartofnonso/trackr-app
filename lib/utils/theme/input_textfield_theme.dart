import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TRKRInputTextFieldTheme {
  TRKRInputTextFieldTheme._();

  static InputDecorationTheme lightTheme = InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.white)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.white)),
    filled: true,
    fillColor: Colors.grey.shade200,
    hintStyle: GoogleFonts.ubuntu(color: Colors.grey.shade600, fontSize: 14),
  );

  static InputDecorationTheme darkTheme = InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Colors.grey)),
    filled: true,
    fillColor: Colors.transparent,
    hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14),
  );
}
