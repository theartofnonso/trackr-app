import 'package:flutter/material.dart';

class TRKRFloatingActionButtonTheme {
  TRKRFloatingActionButtonTheme._();

  static FloatingActionButtonThemeData lightTheme = FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    foregroundColor: Colors.white,
      );

  static FloatingActionButtonThemeData darkTheme = FloatingActionButtonThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    foregroundColor: Colors.black,
  );
}
