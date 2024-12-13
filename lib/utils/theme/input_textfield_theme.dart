import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class TRKRInputTextFieldTheme {
  TRKRInputTextFieldTheme._();

  static InputDecorationTheme lightTheme = InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.grey.shade900)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.grey.shade900)),
    filled: true,
    fillColor: Colors.grey.shade400,
    hintStyle: GoogleFonts.ubuntu(color: Colors.black, fontSize: 14),
  );

  static InputDecorationTheme darkTheme = InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: sapphireLighter)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: sapphireLighter)),
    filled: true,
    fillColor: sapphireDark,
    hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14),
  );
}
