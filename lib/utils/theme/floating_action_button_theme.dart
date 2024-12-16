import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

class TRKRFloatingActionButtonTheme {
  TRKRFloatingActionButtonTheme._();

  static FloatingActionButtonThemeData lightTheme = FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    foregroundColor: Colors.white,
      );

  static FloatingActionButtonThemeData darkTheme = FloatingActionButtonThemeData(
    backgroundColor: sapphireDark80,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    foregroundColor: Colors.black,
  );
}
