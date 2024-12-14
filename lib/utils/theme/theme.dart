import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/theme/app_bar_theme.dart';
import 'package:tracker_app/utils/theme/flaoting_action_button_theme.dart';
import 'package:tracker_app/utils/theme/input_textfield_theme.dart';
import 'package:tracker_app/utils/theme/navigation_bar_theme.dart';
import 'package:tracker_app/utils/theme/text_theme.dart';

import 'icon_theme.dart';
import 'list_title_theme.dart';
import 'menu_theme.dart';

class TRKRTheme {
  TRKRTheme._();

  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Ubuntu",
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Color.fromRGBO(43, 242, 12, 1),
      textTheme: TRKRTextTheme.lightTheme,
      iconTheme: TRKRIconTheme.lightTheme,
      listTileTheme: TRKRListTileTheme.lightTheme,
      navigationBarTheme: TRKRNavigationBarTheme.lightTheme,
      appBarTheme: TRKRAppBarTheme.lightTheme,
      inputDecorationTheme: TRKRInputTextFieldTheme.lightTheme,
      tabBarTheme: TabBarThemeData(
        indicatorColor: Colors.black,
      ),
      menuBarTheme: TRKRMenuBarTheme.lightTheme,
      floatingActionButtonTheme: TRKRFloatingActionButtonTheme.lightTheme);

  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: "Ubuntu",
      brightness: Brightness.dark,
      scaffoldBackgroundColor: sapphireDark80,
      primaryColor: Colors.black,
      textTheme: TRKRTextTheme.darkTheme,
      iconTheme: TRKRIconTheme.darkTheme,
      listTileTheme: TRKRListTileTheme.darkTheme,
      floatingActionButtonTheme: TRKRFloatingActionButtonTheme.darkTheme,
      appBarTheme: TRKRAppBarTheme.darkTheme,
      inputDecorationTheme: TRKRInputTextFieldTheme.darkTheme,
      tabBarTheme: TabBarThemeData(
        indicatorColor: Colors.white,
      ),
      menuBarTheme: TRKRMenuBarTheme.darkTheme,
      navigationBarTheme: TRKRNavigationBarTheme.darkTheme);
}
