import 'package:flutter/material.dart';
import '../../colors.dart';

class TRKRFloatingActionButtonTheme {
  TRKRFloatingActionButtonTheme._();

  static FloatingActionButtonThemeData lightTheme =
      FloatingActionButtonThemeData(
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound)),
    foregroundColor: Colors.white,
  );

  static FloatingActionButtonThemeData darkTheme =
      FloatingActionButtonThemeData(
    backgroundColor: darkSurfaceContainer,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound)),
    foregroundColor: Colors.white,
  );
}
