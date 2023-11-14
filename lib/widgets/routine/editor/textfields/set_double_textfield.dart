import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';
import '../../../../utils/general_utils.dart';

class SetDoubleTextField extends StatelessWidget {
  final double initialValue;
  final void Function(double) onChanged;

  const SetDoubleTextField({super.key, required this.initialValue, required this.onChanged});

  double _parseDoubleOrDefault({required bool isDefaultWeightUnit, required String value}) {
    final doubleValue = double.tryParse(value) ?? 0;
    return isDefaultWeightUnit ? doubleValue : toKg(doubleValue);
  }

  @override
  Widget build(BuildContext context) {
    final defaultWeightUnit = isDefaultWeightUnit();
    final value = defaultWeightUnit ? initialValue : toLbs(initialValue);
    return TextField(
      key: UniqueKey(),
      onChanged: (value) =>
          onChanged(_parseDoubleOrDefault(isDefaultWeightUnit: defaultWeightUnit, value: value)),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          fillColor: tealBlueLight,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          hintText: value.toString(),
          hintStyle: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.grey)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }
}