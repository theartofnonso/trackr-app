import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/exercise/exercise_equipment_enum.dart';

import '../../../colors.dart';
import '../../buttons/opacity_button_widget.dart';
import '../../dividers/label_container.dart';

class ExerciseEquipmentPicker extends StatefulWidget {
  final ExerciseEquipment? initialEquipment;
  final void Function(ExerciseEquipment equipment) onSelect;

  const ExerciseEquipmentPicker({super.key, this.initialEquipment, required this.onSelect});

  @override
  State<ExerciseEquipmentPicker> createState() => _ExerciseEquipmentPickerState();
}

class _ExerciseEquipmentPickerState extends State<ExerciseEquipmentPicker> {
  ExerciseEquipment _selectedEquipment = ExerciseEquipment.barbell;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final equipment = ExerciseEquipment.values;

    final children = ExerciseEquipment.values
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LabelContainer(
          label: "Training Equipment".toUpperCase(),
          description: _selectedEquipment.description,
          labelStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
          descriptionStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 14),
          dividerColor: sapphireLighter,
          labelAlignment: LabelAlignment.left,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _selectedEquipment = equipment[index];
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
              widget.onSelect(_selectedEquipment);
            },
            label: "Switch to ${_selectedEquipment.name}",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = ExerciseEquipment.values.indexOf(widget.initialEquipment ?? ExerciseEquipment.barbell);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
