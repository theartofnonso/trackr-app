import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/general_utils.dart';

class DoubleTextField extends StatelessWidget {
  final num value;
  final TextEditingController controller;
  final void Function(double value) onChanged;

  const DoubleTextField({super.key, required this.value, required this.controller, required this.onChanged});

  double _parseDoubleOrDefault({required String value}) {
    return double.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) => onChanged(_parseDoubleOrDefault(value: value)),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Colors.transparent)),
          fillColor: Colors.transparent,
          hintText: "${value > 0 ? weightWithConversion(value: value) : '-'}",
          hintStyle: GoogleFonts.montserrat(color: Colors.white70)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}
