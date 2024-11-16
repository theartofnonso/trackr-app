import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../colors.dart';
import '../../buttons/opacity_button_widget.dart';
import '../../dividers/label_container.dart';

class ExerciseStancePicker extends StatefulWidget {
  final ExerciseStance? initialStance;
  final List<ExerciseStance> stances;
  final void Function(ExerciseStance position) onSelect;

  const ExerciseStancePicker({super.key, this.initialStance, required this.stances, required this.onSelect});

  @override
  State<ExerciseStancePicker> createState() => _ExerciseStancePickerState();
}

class _ExerciseStancePickerState extends State<ExerciseStancePicker> {
  ExerciseStance _selectedStance = ExerciseStance.standing;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final children = widget.stances
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LabelContainer(
          label: "Training Stance".toUpperCase(),
          description: _selectedStance.description,
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
                _selectedStance = widget.stances[index];
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
              widget.onSelect(_selectedStance);
            },
            label: "Switch to ${_selectedStance.name}",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.stances.indexOf(widget.initialStance ?? ExerciseStance.standing);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
