import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_constants.dart';

class CSearchBar extends StatelessWidget {
  final Function(String)? onChanged;
  final String hintText;
  const CSearchBar({super.key, this.onChanged, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      onChanged: onChanged,
      leading: const Icon(
        Icons.search_rounded,
        color: Colors.white70,
      ),
      hintText: hintText,
      hintStyle: MaterialStatePropertyAll<TextStyle>(GoogleFonts.lato(color: Colors.white70)),
      textStyle: MaterialStatePropertyAll<TextStyle>(GoogleFonts.lato(color: Colors.white)),
      surfaceTintColor: const MaterialStatePropertyAll<Color>(tealBlueLight),
      backgroundColor: const MaterialStatePropertyAll<Color>(tealBlueLight),
      shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      )),
      constraints: const BoxConstraints(minHeight: 50),
    );
  }
}
