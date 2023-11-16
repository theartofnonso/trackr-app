import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';

class SetIntTextField extends StatefulWidget {
  final int value;
  final UniqueKey uniqueKey;
  final void Function(int) onChanged;

  const SetIntTextField({
    required this.value,
    required this.uniqueKey,
    required this.onChanged,
  }) : super(key: uniqueKey);

  @override
  State<SetIntTextField> createState() => _SetIntTextFieldState();
}

class _SetIntTextFieldState extends State<SetIntTextField> {
  late TextEditingController _controller;

  int _parseIntOrDefault({required String value}) {
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => widget.onChanged(_parseIntOrDefault(value: value.toString())),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLight)),
          fillColor: tealBlueLight,
          hintText: widget.value > 0 ? widget.value.toString() : "-",
          hintStyle: GoogleFonts.lato(color: Colors.white70)),
      keyboardType: TextInputType.number,
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
