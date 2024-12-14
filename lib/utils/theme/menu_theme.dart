import 'package:flutter/material.dart';

import '../../colors.dart';

class TRKRMenuBarTheme {
  TRKRMenuBarTheme._();

  static MenuBarThemeData lightTheme = MenuBarThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade200),
      surfaceTintColor: WidgetStateProperty.all(Colors.grey.shade200),
    )
  );

  static MenuBarThemeData darkTheme = MenuBarThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(sapphireDark80),
        surfaceTintColor: WidgetStateProperty.all(sapphireDark),
      )
  );
}
