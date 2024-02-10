import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class CSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final Function() onClear;
  final String hintText;
  final TextEditingController controller;

  const CSearchBar({super.key, required this.onChanged, required this.onClear, required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {

    return SearchBar(
      controller: controller,
      onChanged: onChanged,
      leading: const Icon(
        Icons.search_rounded,
        color: Colors.white70,
      ),
      trailing: [IconButton(onPressed: onClear, icon: const Icon(Icons.cancel, color: Colors.white70), visualDensity: VisualDensity.compact,)],
      hintText: hintText,
      hintStyle: MaterialStatePropertyAll<TextStyle>(GoogleFonts.montserrat(color: Colors.white70)),
      textStyle: MaterialStatePropertyAll<TextStyle>(GoogleFonts.montserrat(color: Colors.white)),
      surfaceTintColor: const MaterialStatePropertyAll<Color>(sapphireLight),
      backgroundColor: MaterialStatePropertyAll<Color>(sapphireDark.withOpacity(0.8)),
      shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      )),
      constraints: const BoxConstraints(minHeight: 50),
    );
  }
}
