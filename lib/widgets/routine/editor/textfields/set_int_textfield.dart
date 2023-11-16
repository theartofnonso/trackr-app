import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class SetIntTextField extends StatelessWidget {
  final int value;
  final TextEditingController editingController;
  final void Function(int) onChanged;

  const SetIntTextField({
    super.key,
    required this.value,
    required this.editingController,
    required this.onChanged,
  });

  int _parseIntOrDefault({required String value}) {
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: editingController,
      onChanged: (_) => onChanged(_parseIntOrDefault(value: editingController.text)),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          fillColor: tealBlueLight,
          hintText: value > 0 ? value.toString() : "-",
          hintStyle: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.grey)),
      keyboardType: TextInputType.number,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}
