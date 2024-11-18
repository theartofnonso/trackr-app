import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../enums/exercise/exercise_movement_enum.dart';
import '../../buttons/opacity_button_widget.dart';
import '../../dividers/label_container.dart';

class ExerciseMovementPicker extends StatefulWidget {
  final ExerciseMovement? initialMovement;
  final List<ExerciseMovement> movements;
  final void Function(ExerciseMovement position) onSelect;

  const ExerciseMovementPicker({super.key, this.initialMovement, required this.movements, required this.onSelect});

  @override
  State<ExerciseMovementPicker> createState() => _ExerciseMovementPickerState();
}

class _ExerciseMovementPickerState extends State<ExerciseMovementPicker> {

  ExerciseMovement _selectedMovement = ExerciseMovement.none;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final children = widget.movements
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LabelContainer(
          label: "Training movement".toUpperCase(),
          description: _selectedMovement.description,
          labelStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
          descriptionStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 14),
          dividerColor: sapphireLighter,
          labelAlignment: LabelAlignment.left,
        ),
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedMovement = widget.movements[index];
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
              widget.onSelect(_selectedMovement);
            },
            label: "Switch to ${_selectedMovement.name}",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.movements.indexOf(widget.initialMovement ?? ExerciseMovement.none);
    _selectedMovement = widget.movements[initialIndex];
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
