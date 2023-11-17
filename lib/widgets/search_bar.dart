import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_constants.dart';

class CSearchBar extends StatefulWidget {
  final Function(String) onChanged;
  final Function() onClear;
  final String hintText;
  const CSearchBar({super.key, required this.onChanged, required this.onClear, required this.hintText});

  @override
  State<CSearchBar> createState() => _CSearchBarState();
}

class _CSearchBarState extends State<CSearchBar> {

  late TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return SearchBar(
      controller: _controller,
      onChanged: widget.onChanged,
      leading: const Icon(
        Icons.search_rounded,
        color: Colors.white70,
      ),
      trailing: [IconButton(onPressed: () {
        _controller.clear();
        widget.onClear();
      }, icon: const Icon(Icons.cancel, color: Colors.white70), visualDensity: VisualDensity.compact,)],
      hintText: widget.hintText,
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
