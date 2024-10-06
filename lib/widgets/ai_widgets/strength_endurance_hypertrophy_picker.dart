import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/strength_endurance_hypertrophy_enums.dart';

import '../buttons/opacity_button_widget.dart';

class StrengthEnduranceHypertrophyPicker extends StatefulWidget {
  final void Function(StrengthEnduranceHypertrophyType type) onSelect;

  const StrengthEnduranceHypertrophyPicker({super.key, required this.onSelect});

  @override
  State<StrengthEnduranceHypertrophyPicker> createState() => _StrengthEnduranceHypertrophyPickerState();
}

class _StrengthEnduranceHypertrophyPickerState extends State<StrengthEnduranceHypertrophyPicker> {
  StrengthEnduranceHypertrophyType _type = StrengthEnduranceHypertrophyType.strength;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final type = _type;

    final children = StrengthEnduranceHypertrophyType.values
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 28, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        RichText(
            text: TextSpan(
                text: "Strength".toUpperCase(),
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w700),
                children: [
              const TextSpan(text: " "),
              TextSpan(
                  text:
                      "exercises boosts muscle growth, strengthens bones, enhances metabolism, improves functional fitness, and reduces injury risk.",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
              const TextSpan(text: "\n"),
              const TextSpan(text: "\n"),
              TextSpan(text: "Endurance".toUpperCase()),
              const TextSpan(text: " "),
              TextSpan(
                  text: "improves stamina, cardiovascular health, and overall fitness",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
              const TextSpan(text: "\n"),
              const TextSpan(text: "\n"),
              TextSpan(text: "Hypertrophy".toUpperCase()),
              const TextSpan(text: " "),
              TextSpan(
                  text: "improves functional fitness, and reduces injury risk.",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
            ])),
        const SizedBox(height: 6),
        SizedBox(
          height: 100,
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              _type = StrengthEnduranceHypertrophyType.values[index];
            },
            squeeze: 1,
            children: children,
          ),
        ),
        const SizedBox(height: 10),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(type);
            },
            label: "Select",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
