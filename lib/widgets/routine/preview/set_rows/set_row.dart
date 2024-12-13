import 'package:flutter/material.dart';

import '../../../../colors.dart';
import '../../../../dtos/pb_dto.dart';
import '../../../pbs/pb_icon.dart';

class SetRow extends StatelessWidget {
  final List<PBDto> pbs;
  final Widget child;

  const SetRow({super.key, this.pbs = const [], required this.child});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final pbsForSet = pbs
        .map((pb) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: PBIcon(color: sapphireLight, label: pb.pb.name),
            ))
        .toList();

    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5.0),
          border: pbs.isNotEmpty ? Border.all(color: Colors.white12, width: 1) : null // Border color
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
