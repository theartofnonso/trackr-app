import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class DoubleTextField extends StatelessWidget {
  final double value;
  final TextEditingController controller;
  final void Function(double value) onChanged;

  const DoubleTextField({super.key, required this.value, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          fillColor: tealBlueLight,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          hintText: value > 0 ? value.toString() : "-",
          hintStyle: GoogleFonts.lato(color: Colors.white70)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}
