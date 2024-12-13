import 'package:flutter/material.dart';
import 'package:tracker_app/utils/theme/text_theme.dart';

class TRKRTheme {
  TRKRTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Ubuntu",
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Color.fromRGBO(43, 242, 12, 1),
    textTheme: TRKRTextTheme.lightTextTheme
  );

  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Ubuntu",
      brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
      primaryColor: Color.fromRGBO(43, 242, 12, 1),
      textTheme: TRKRTextTheme.darkTextTheme
  );
}