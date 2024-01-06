import 'package:flutter/material.dart';

import '../../../../app_constants.dart';
import '../../../chips/chip_1.dart';
import '../exercise_log_widget.dart';

class SetRow extends StatelessWidget {
  final EdgeInsets? margin;
  final PBViewModel? pbViewModel;
  final Widget child;

  const SetRow({super.key, this.margin, this.pbViewModel, required this.child});

  @override
  Widget build(BuildContext context) {
    final pb = pbViewModel;

    final pbs = pb?.pbs.map((pb) => ChipOne(color: tealBlueLight, label: pb.name)).toList();

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: pbs != null ? tealBlueDark : tealBlueLight, // Container color
        borderRadius: BorderRadius.circular(5.0),
        border: pbs != null ? Border.all(color: tealBlueLight, width: 2) : null, // Border color
        // Radius for rounded corners
      ),
      padding: pbs != null ? const EdgeInsets.only(top: 16) : const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          child,
          if (pbs != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: pbs),
            )
        ],
      ),
    );
  }
}