import 'package:flutter/material.dart';
import 'package:tracker_app/utils/theme/flaoting_action_button_theme.dart';
import 'package:tracker_app/utils/theme/navigation_bar_theme.dart';
import 'package:tracker_app/utils/theme/text_theme.dart';

import 'icon_theme.dart';
import 'list_title_theme.dart';

class TRKRTheme {
  TRKRTheme._();

  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Ubuntu",
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Color.fromRGBO(43, 242, 12, 1),
      textTheme: TRKRTextTheme.lightTextTheme,
      iconTheme: TRKRIconTheme.lightIconTheme,
      listTileTheme: TRKRListTileTheme.lightTheme,
      navigationBarTheme: TRKRNavigationBarTheme.lightNavigationBarTheme,
  floatingActionButtonTheme: TRKRFloatingActionButtonTheme.lightTheme);

  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Ubuntu",
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Color.fromRGBO(43, 242, 12, 1),
      textTheme: TRKRTextTheme.darkTextTheme,
      iconTheme: TRKRIconTheme.darkIconTheme,
      listTileTheme: TRKRListTileTheme.darkTheme,
      floatingActionButtonTheme: TRKRFloatingActionButtonTheme.darkTheme,
      navigationBarTheme: TRKRNavigationBarTheme.darkNavigationBarTheme);
}
