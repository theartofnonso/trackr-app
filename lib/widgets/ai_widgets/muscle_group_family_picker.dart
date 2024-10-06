import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../buttons/opacity_button_widget.dart';

class MuscleGroupFamilyPicker extends StatefulWidget {
  final void Function(MuscleGroupFamily family) onSelect;

  const MuscleGroupFamilyPicker({super.key, required this.onSelect});

  @override
  State<MuscleGroupFamilyPicker> createState() => _MuscleGroupFamilyPickerState();
}

class _MuscleGroupFamilyPickerState extends State<MuscleGroupFamilyPicker> {
  MuscleGroupFamily _type = MuscleGroupFamily.fullBody;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final type = _type;

    final children = MuscleGroupFamily.values
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 28, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        RichText(
            text:
                TextSpan(text: "Legs".toUpperCase(), style: GoogleFonts.ubuntu(fontWeight: FontWeight.w700), children: [
          const TextSpan(text: " "),
          TextSpan(
              text: "builds strength, stability, and power for improved daily movement",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Back".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "enhance posture, support spine health, and improve pulling strength.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Arms".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "boost upper body strength and endurance for functional tasks.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Chest".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "strengthens pushing power and improves upper body balance.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Shoulders".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "improves mobility, stability, and upper body strength.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Core".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "boosts balance, posture, and injury prevention.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Neck".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "improves posture and reduces risk of neck strain.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Full Body".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "promotes balanced muscle development and calorie burn.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
          const TextSpan(text: "\n"),
          const TextSpan(text: "\n"),
          TextSpan(text: "Cardio".toUpperCase()),
          const TextSpan(text: " "),
          TextSpan(
              text: "improves heart health, endurance, and boosting energy levels.",
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
        ])),
        const SizedBox(height: 6),
        SizedBox(
          height: 140,
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              _type = MuscleGroupFamily.values[index];
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
