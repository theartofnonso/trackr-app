import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/full_upper_lower_core_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/strength_endurance_hypertrophy_enums.dart';

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
        Expanded(
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
