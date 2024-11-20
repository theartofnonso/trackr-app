import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import '../../../colors.dart';
import '../../buttons/opacity_button_widget.dart';
import '../../dividers/label_container.dart';

class ExerciseConfigurationsPicker<Enum> extends StatefulWidget {
  final String label;
  final Enum? initialConfig;
  final List<ExerciseConfig> configurationOptions;
  final void Function(ExerciseConfig configuration) onSelect;

  const ExerciseConfigurationsPicker(
      {super.key, required this.label, this.initialConfig, required this.configurationOptions, required this.onSelect});

  @override
  State<ExerciseConfigurationsPicker> createState() => _ExerciseConfigurationsPickerState();
}

class _ExerciseConfigurationsPickerState<Enum> extends State<ExerciseConfigurationsPicker<Enum>> {
  late ExerciseConfig _selectedConfig;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final children = widget.configurationOptions
        .map((config) => Center(
            child: Text(config.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LabelContainer(
          label: widget.label.toUpperCase(),
          description: _selectedConfig.description,
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
                _selectedConfig = widget.configurationOptions[index];
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
              widget.onSelect(_selectedConfig);
            },
            label: "Switch to ${_selectedConfig.name}",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.configurationOptions.isEmpty) {
      throw ArgumentError('Configuration Options list cannot be empty.');
    }
    final initialIndex =
        widget.initialConfig != null ? widget.configurationOptions.indexOf(widget.initialConfig as ExerciseConfig) : 0;
    _selectedConfig = widget.configurationOptions[initialIndex];
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
