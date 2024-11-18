import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../enums/exercise/exercise_metrics_enums.dart';
import '../../buttons/opacity_button_widget.dart';
import '../../dividers/label_container.dart';

class ExerciseMetricPicker extends StatefulWidget {
  final ExerciseMetric? initialMetric;
  final List<ExerciseMetric> metrics;
  final void Function(ExerciseMetric metric) onSelect;

  const ExerciseMetricPicker({super.key, this.initialMetric, required this.metrics, required this.onSelect});

  @override
  State<ExerciseMetricPicker> createState() => _ExerciseMetricPickerState();
}

class _ExerciseMetricPickerState extends State<ExerciseMetricPicker> {
  ExerciseMetric _selectedMetric = ExerciseMetric.weights;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final children = widget.metrics
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LabelContainer(
          label: "Logging Metric".toUpperCase(),
          description: _selectedMetric.description,
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
                _selectedMetric = widget.metrics[index];
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
              widget.onSelect(_selectedMetric);
            },
            label: "Switch to ${_selectedMetric.name} metrics",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.metrics.indexOf(widget.initialMetric ?? ExerciseMetric.weights);
    _selectedMetric = widget.metrics[initialIndex];
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
