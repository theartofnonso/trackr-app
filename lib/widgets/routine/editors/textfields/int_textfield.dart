import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class IntTextField extends StatelessWidget {
  final int value;
  final int? pastValue;
  final TextEditingController controller;
  final void Function(int value) onChanged;

  const IntTextField({super.key, required this.value, required this.pastValue, required this.controller, required this.onChanged});

  int _parseIntOrDefault({required String value}) {
    final parsedOrZero = int.tryParse(value) ?? 0;
    final pastOrZero = pastValue ?? 0;
    return parsedOrZero > 0 ? parsedOrZero : pastOrZero;
  }

  String _value() {
    int valueOrPast = pastValue ?? value;
    return valueOrPast > 0 ? valueOrPast.toString() : "-";
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) => onChanged(_parseIntOrDefault(value: value)),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          fillColor: tealBlueLight,
          hintText: _value(),
          hintStyle: GoogleFonts.lato(color: Colors.white70)),
      keyboardType: TextInputType.number,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}
