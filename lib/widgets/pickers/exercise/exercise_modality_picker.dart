import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/dividers/label_container.dart';

import '../../../colors.dart';
import '../../../enums/exercise/exercise_modality_enum.dart';
import '../../buttons/opacity_button_widget.dart';

class ExerciseModalityPicker extends StatefulWidget {
  final ExerciseModality? initialModality;
  final List<ExerciseModality> modes;
  final void Function(ExerciseModality modality) onSelect;

  const ExerciseModalityPicker({super.key, this.initialModality, required this.modes, required this.onSelect});

  @override
  State<ExerciseModalityPicker> createState() => _ExerciseModalityPickerState();
}

class _ExerciseModalityPickerState extends State<ExerciseModalityPicker> {
  ExerciseModality _selectedMode = ExerciseModality.bilateral;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {

    final children = widget.modes
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LabelContainer(
          label: "Training Modality".toUpperCase(),
          description: _selectedMode.description,
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
                _selectedMode = widget.modes[index];
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
              widget.onSelect(_selectedMode);
            },
            label: "Switch to ${_selectedMode.name} movements",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.modes.indexOf(widget.initialModality ?? ExerciseModality.bilateral);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
