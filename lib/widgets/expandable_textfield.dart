import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableTextFieldWidget extends StatelessWidget {
  final Function(String) onChanged;
  final Function() onClear;
  final String hintText;
  final TextEditingController controller;

  const ExpandableTextFieldWidget({super.key, required this.onChanged, required this.onClear, required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: controller,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white30)),
          filled: true,
          fillColor: Colors.white10,
          hintText: "Ask TRKR Coach",
          hintStyle: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400)),
      maxLines: null,
      cursorColor: Colors.white,
      showCursor: true,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.ubuntu(
          fontWeight: FontWeight.w400, color: Colors.white, fontSize: 16),
    );
  }
}
