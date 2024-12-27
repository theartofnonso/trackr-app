import 'package:flutter/material.dart';

class IntTextField extends StatelessWidget {
  final int value;
  final TextEditingController controller;
  final void Function(int value) onChanged;
  final void Function() onTap;

  const IntTextField(
      {super.key, required this.value, required this.controller, required this.onChanged, required this.onTap});

  int _parseIntOrDefault({required String value}) {
    return int.tryParse(value) ?? 0;
  }

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return TextField(
      controller: controller,
      cursorColor: isDarkMode ? Colors.white : Colors.black,
      onChanged: (value) => onChanged(_parseIntOrDefault(value: value)),
      onTap: onTap,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Colors.transparent)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Colors.transparent)),
          hintText: "${value > 0 ? value : '-'}"),
      keyboardType: TextInputType.number,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }
}
