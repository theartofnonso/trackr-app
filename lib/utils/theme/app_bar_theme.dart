import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TRKRAppBarTheme {
  TRKRAppBarTheme._();

  static AppBarTheme lightTheme = AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actionsIconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 16));

  static AppBarTheme darkTheme = AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actionsIconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16));
}
