import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import 'icon_theme.dart';

class TRKRAppBarTheme {
  TRKRAppBarTheme._();

  static AppBarTheme lightTheme = AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actionsIconTheme: TRKRIconTheme.lightTheme,
      titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 16));

  static AppBarTheme darkTheme = AppBarTheme(
      backgroundColor: sapphireDark80,
      foregroundColor: Colors.white,
      actionsIconTheme: TRKRIconTheme.darkTheme,
      titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16));
}
