import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../utils/general_utils.dart';
import '../buttons/opacity_button_widget.dart';

class WeightPicker extends StatefulWidget {
  final int initialWeight;
  final void Function(int weight) onSelect;

  const WeightPicker({super.key, required this.onSelect, required this.initialWeight});

  @override
  State<WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  int _weight = 0;

  FixedExtentScrollController? _scrollController;

  List<int> _weights = [];

  @override
  Widget build(BuildContext context) {
    final weights = _weights
        .map((weight) => Center(
        child: Text("$weight",
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
              _weight = _weights[index];
            },
            squeeze: 1,
            selectionOverlay: Container(color: Colors.transparent),
            children: weights,
          ),
        ),
        const SizedBox(height: 16),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(_weight);
            },
            label: "Select Weight",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final min = isDefaultWeightUnit() ? 23 : 51;
    final max = isDefaultWeightUnit() ? 204 - 23 + 1 : 450 - 51 + 1;
    _weights = List.generate(max, (index) => min + index);
    final initialIndex = _weights.indexOf(widget.initialWeight);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}