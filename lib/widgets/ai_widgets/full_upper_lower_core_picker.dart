import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/full_upper_lower_core_type_enums.dart';
import 'package:tracker_app/enums/strength_endurance_hypertrophy_enums.dart';

import '../buttons/opacity_button_widget.dart';

class FullUpperLowerCorePicker extends StatefulWidget {
  final void Function(FullUpperLowerCoreType type) onSelect;

  const FullUpperLowerCorePicker({super.key, required this.onSelect});

  @override
  State<FullUpperLowerCorePicker> createState() => _FullUpperLowerCorePickerState();
}

class _FullUpperLowerCorePickerState extends State<FullUpperLowerCorePicker> {
  FullUpperLowerCoreType _type = FullUpperLowerCoreType.full;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final type = _type;

    final children = FullUpperLowerCoreType.values
        .map((value) => Center(
            child: Text(value.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 28, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              _type = FullUpperLowerCoreType.values[index];
            },
            squeeze: 1,
            children: children,
          ),
        ),
        const SizedBox(height: 10),
        OpacityButtonWidget(
            onPressed: () {
                    widget.onSelect(type);
                  },
            label: "Select",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
