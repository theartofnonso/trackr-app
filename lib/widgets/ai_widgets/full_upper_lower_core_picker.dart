import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/full_upper_lower_core_type_enums.dart';

import '../buttons/opacity_button_widget.dart';

class FullUpperLowerCorePicker extends StatefulWidget {
  final void Function(FullUpperLowerCoreType type) onSelect;

  const FullUpperLowerCorePicker({super.key, required this.onSelect});

  @override
  State<FullUpperLowerCorePicker> createState() => _FullUpperLowerCorePickerState();
}

class _FullUpperLowerCorePickerState extends State<FullUpperLowerCorePicker> {
  FullUpperLowerCoreType _type = FullUpperLowerCoreType.full;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final type = _type;

    final children = FullUpperLowerCoreType.values
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 28, color: Colors.white))))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          RichText(
              text: TextSpan(
                  text: "Full Body".toUpperCase(),
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w700),
                  children: [
                    const TextSpan(text: " "),
                    TextSpan(text: "promotes balanced muscle growth, improves functional fitness, saves time, boosts calorie burn, and enhances recovery.",  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
                    const TextSpan(text: "\n"),
                    const TextSpan(text: "\n"),
                    TextSpan(text: "Upper Body".toUpperCase()),
                    const TextSpan(text: " "),
                    TextSpan(text: "strengthens arms, shoulders, chest, and back for better posture, functional strength, and aesthetics", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
                    const TextSpan(text: "\n"),
                    const TextSpan(text: "\n"),
                    TextSpan(text: "Lower Body".toUpperCase()),
                    const TextSpan(text: " "),
                    TextSpan(text: "builds leg strength, improves stability, and enhances athletic performance.", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
                    const TextSpan(text: "\n"),
                    const TextSpan(text: "\n"),
                    TextSpan(text: "Core".toUpperCase()),
                    const TextSpan(text: " "),
                    TextSpan(text: "strengthens the abs, obliques, and lower back for improved balance, posture, and injury prevention.", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70)),
                  ])),
          const SizedBox(height: 6),
          SizedBox(
            height: 140,
            child: CupertinoPicker(
              scrollController: _scrollController,
              itemExtent: 38.0,
              onSelectedItemChanged: (int index) {
                _type = FullUpperLowerCoreType.values[index];
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
      ),
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
