import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/exercise/exercise_modality_enum.dart';
import '../buttons/opacity_button_widget.dart';

class ExerciseModalityPicker extends StatefulWidget {
  final ExerciseModality? initialModality;
  final void Function(ExerciseModality modality) onSelect;

  const ExerciseModalityPicker({super.key, this.initialModality, required this.onSelect});

  @override
  State<ExerciseModalityPicker> createState() => _ExerciseModalityPickerState();
}

class _ExerciseModalityPickerState extends State<ExerciseModalityPicker> {
  ExerciseModality _mode = ExerciseModality.bilateral;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final modes = ExerciseModality.values;

    final children = ExerciseModality.values
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _mode = modes[index];
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
              widget.onSelect(_mode);
            },
            label: "Training with ${_mode.name} movements",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = ExerciseModality.values.indexOf(widget.initialModality ?? ExerciseModality.bilateral);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
