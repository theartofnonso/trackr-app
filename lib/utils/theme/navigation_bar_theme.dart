import 'package:flutter/material.dart';

class TRKRNavigationBarTheme {
  TRKRNavigationBarTheme._();

  static NavigationBarThemeData lightNavigationBarTheme = NavigationBarThemeData(
    indicatorColor: Colors.transparent,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
  );

  static NavigationBarThemeData darkNavigationBarTheme = NavigationBarThemeData(
    indicatorColor: Colors.transparent,
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.black,
    overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
  );
}
