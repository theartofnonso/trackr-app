import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../utils/theme/list_title_theme.dart';

class OutlineListTile extends StatelessWidget {
  final String title;
  final String? trailing;
  final void Function() onTap;

  const OutlineListTile({super.key, required this.onTap, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final trailing = this.trailing;

    return Theme(data: Theme.of(context).copyWith(listTileTheme: isDarkMode ? TRKRListTileTheme.darkTheme : TRKRListTileTheme.lightTheme),
        child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        splashColor: sapphireLighter,
        onTap: onTap,
        title: Text(title),
        trailing: trailing != null ? Text(trailing) : null));
  }
}
