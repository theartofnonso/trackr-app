import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

class TRKRNavigationBarTheme {
  TRKRNavigationBarTheme._();

  static NavigationBarThemeData lightTheme = NavigationBarThemeData(
    indicatorColor: Colors.transparent,
    backgroundColor: Colors.grey.shade200,
    surfaceTintColor: Colors.white,
    overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
  );

  static NavigationBarThemeData darkTheme = NavigationBarThemeData(
    indicatorColor: Colors.transparent,
    backgroundColor: sapphireDark80,
    surfaceTintColor: Colors.black,
    overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
  );
}
