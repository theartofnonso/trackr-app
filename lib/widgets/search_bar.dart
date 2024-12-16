import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class CSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final Function() onClear;
  final String hintText;
  final TextEditingController controller;

  const CSearchBar(
      {super.key, required this.onChanged, required this.onClear, required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return SearchBar(
      controller: controller,
      onChanged: onChanged,
      leading: const Icon(
        Icons.search_rounded,
      ),
      trailing: [
        IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.cancel, color: Colors.white70),
          visualDensity: VisualDensity.compact,
        )
      ],
      hintText: hintText,
      hintStyle: WidgetStatePropertyAll<TextStyle>(GoogleFonts.ubuntu(color: Colors.white70)),
      textStyle: WidgetStatePropertyAll<TextStyle>(GoogleFonts.ubuntu(color: Colors.white)),
      surfaceTintColor: WidgetStatePropertyAll<Color>(isDarkMode ? sapphireLight : Colors.grey.shade900),
      backgroundColor: WidgetStatePropertyAll<Color>(isDarkMode ? sapphireDark.withOpacity(0.8) : Colors.grey.shade400),
      shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      )),
      constraints: const BoxConstraints(minHeight: 50),
    );
  }
}
