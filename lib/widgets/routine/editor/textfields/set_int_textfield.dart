import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class SetIntTextField extends StatelessWidget {
  final int value;
  final String setId;
  final TextEditingController controller;
  final void Function(int value) onChanged;

  const SetIntTextField({super.key, required this.value, required this.onChanged, required this.setId, required this.controller});

  int _parseIntOrDefault({required String value}) {
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      //initialValue: value > 0 ? value.toString() : null,
      //key: ValueKey(setId),
      controller: controller,
      onChanged: (value) => onChanged(_parseIntOrDefault(value: value.toString())),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          fillColor: tealBlueLight,
          hintText: value > 0 ? value.toString() : "-",
          hintStyle: GoogleFonts.lato(color: Colors.white70)),
      keyboardType: TextInputType.number,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}
