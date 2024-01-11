import 'package:flutter/material.dart';

import '../../../../app_constants.dart';
import '../../../chips/chip_1.dart';
import '../exercise_log_widget.dart';

class SetRow extends StatelessWidget {
  final EdgeInsets? margin;
  final List<PBDto> pbs;
  final Widget child;

  const SetRow({super.key, this.margin, this.pbs = const [], required this.child});

  @override
  Widget build(BuildContext context) {

    final pbsForSet = pbs.map((pb) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ChipOne(color: tealBlueLight, label: pb.pb.name),
    )).toList();

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: pbs.isNotEmpty ? tealBlueDark : tealBlueLight, // Container color
        borderRadius: BorderRadius.circular(5.0),
        border: pbs.isNotEmpty ? Border.all(color: tealBlueLight, width: 2) : null, // Border color
        // Radius for rounded corners
      ),
      padding: pbs.isNotEmpty ? const EdgeInsets.only(top: 16) : const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          child,
          if (pbs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: pbsForSet),
            )
        ],
      ),
    );
  }
}
