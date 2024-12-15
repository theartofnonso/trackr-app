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
    final pbsForSet = pbs
        .map((pb) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: PBIcon(color: sapphireLight, label: pb.pb.name),
            ))
        .toList();

    return Column(
      children: [
        child,
        if (pbs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 14.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: pbsForSet),
          )
      ],
    );
  }
}
