import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';
import '../../../../utils/general_utils.dart';

class SetDoubleTextField extends StatefulWidget {
  final double value;
  final UniqueKey uniqueKey;
  final void Function(double) onChanged;

  const SetDoubleTextField({required this.value, required this.uniqueKey, required this.onChanged}) : super(key: uniqueKey);

  @override
  State<SetDoubleTextField> createState() => _SetDoubleTextFieldState();
}

class _SetDoubleTextFieldState extends State<SetDoubleTextField> {

  late TextEditingController _controller;

  double _parseDoubleOrDefault({required bool isDefaultWeightUnit, required String value}) {
    final doubleValue = double.tryParse(value) ?? 0;
    return isDefaultWeightUnit ? doubleValue : toKg(doubleValue);
  }

  @override
  Widget build(BuildContext context) {
    final defaultWeightUnit = isDefaultWeightUnit();
    return TextField(
      controller: _controller,
      onChanged: (value) => widget.onChanged(_parseDoubleOrDefault(isDefaultWeightUnit: defaultWeightUnit, value: value)),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          fillColor: tealBlueLight,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          hintText: widget.value > 0 ? widget.value.toString() : "-",
          hintStyle: GoogleFonts.lato(color: Colors.white70)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLines: 1,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
