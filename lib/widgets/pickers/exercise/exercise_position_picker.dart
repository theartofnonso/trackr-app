import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../enums/exercise/exercise_position_enum.dart';
import '../../buttons/opacity_button_widget.dart';
import '../../dividers/label_container.dart';

class ExercisePositionPicker extends StatefulWidget {
  final ExercisePosition? initialPosition;
  final List<ExercisePosition> positions;
  final void Function(ExercisePosition position) onSelect;

  const ExercisePositionPicker({super.key, this.initialPosition, required this.positions, required this.onSelect});

  @override
  State<ExercisePositionPicker> createState() => _ExercisePositionPickerState();
}

class _ExercisePositionPickerState extends State<ExercisePositionPicker> {
  ExercisePosition _selectedPosition = ExercisePosition.neutral;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final children = widget.positions
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LabelContainer(
          label: "Training Position".toUpperCase(),
          description: _selectedPosition.description,
          labelStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
          descriptionStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 14),
          dividerColor: Colors.transparent,
          labelAlignment: LabelAlignment.left,
        ),
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedPosition = widget.positions[index];
              });
            },
            squeeze: 1,
            selectionOverlay: Container(color: Colors.transparent),
            children: children,
          ),
        ),
        const SizedBox(height: 16),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(_selectedPosition);
            },
            label: "Switch to ${_selectedPosition.name} position",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.positions.indexOf(widget.initialPosition ?? ExercisePosition.neutral);
    _selectedPosition = widget.positions[initialIndex];
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
