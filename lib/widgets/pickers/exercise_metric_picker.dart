import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/exercise/exercise_metrics_enums.dart';
import '../buttons/opacity_button_widget.dart';

class ExerciseMetricPicker extends StatefulWidget {
  final ExerciseMetric? initialMetric;
  final void Function(ExerciseMetric metric) onSelect;

  const ExerciseMetricPicker({super.key, this.initialMetric, required this.onSelect});

  @override
  State<ExerciseMetricPicker> createState() => _ExerciseMetricPickerState();
}

class _ExerciseMetricPickerState extends State<ExerciseMetricPicker> {
  ExerciseMetric _metric = ExerciseMetric.weights;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final metrics = ExerciseMetric.values;

    final children = ExerciseMetric.values
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
               _metric = metrics[index];
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
              widget.onSelect(_metric);
            },
            label: "Log ${_metric.name}",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = ExerciseMetric.values.indexOf(widget.initialMetric ?? ExerciseMetric.weights);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
