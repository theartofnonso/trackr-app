import 'package:flutter/material.dart';
import '../../colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TRKRInputTextFieldTheme {
  TRKRInputTextFieldTheme._();

  static InputDecorationTheme lightTheme = InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(color: Colors.black38)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(color: Colors.black38)),
    filled: true,
    fillColor: Colors.grey.shade200,
    hintStyle: GoogleFonts.ubuntu(color: Colors.grey.shade600, fontSize: 14),
  );

  static InputDecorationTheme darkTheme = InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(color: Colors.white10)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(color: Colors.white10)),
    filled: true,
    fillColor: Colors.transparent,
    hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14),
  );
}
