import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../colors.dart';
import '../buttons/opacity_button_widget.dart';

class MusclePicker extends StatefulWidget {
  final MuscleGroup? initialMuscleGroup;
  final void Function(MuscleGroup muscleGroup) onSelect;

  const MusclePicker({super.key, this.initialMuscleGroup, required this.onSelect});

  @override
  State<MusclePicker> createState() => _MusclePickerState();
}

class _MusclePickerState extends State<MusclePicker> {
  MuscleGroup _muscleGroup = MuscleGroup.abs;

  FixedExtentScrollController? _scrollController;

  List<MuscleGroup> _muscleGroups = [];

  @override
  Widget build(BuildContext context) {
    final muscleGroups = _muscleGroups
        .map((muscleGroup) => Center(
            child: Text(muscleGroup.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 32, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              _muscleGroup = _muscleGroups[index];
            },
            squeeze: 1,
            selectionOverlay: Container(color: Colors.transparent),
            children: muscleGroups,
          ),
        ),
        const SizedBox(height: 16),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(_muscleGroup);
            },
            label: "Select Muscle Group",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _muscleGroups = MuscleGroup.values.sorted((a, b) => a.name.compareTo(b.name));
    final initialIndex = _muscleGroups.indexOf(widget.initialMuscleGroup ?? MuscleGroup.abs);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
