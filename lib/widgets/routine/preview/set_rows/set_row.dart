import 'package:flutter/material.dart';

import '../../../../colors.dart';
import '../../../../dtos/pb_dto.dart';
import '../../../../enums/routine_preview_type_enum.dart';
import '../../../pbs/pb_icon.dart';

class SetRow extends StatelessWidget {
  final EdgeInsets? margin;
  final List<PBDto> pbs;
  final Widget child;
  final RoutinePreviewType routinePreviewType;

  const SetRow({super.key, this.margin, this.pbs = const [], required this.child, required this.routinePreviewType});

  @override
  Widget build(BuildContext context) {

    final pbsForSet = pbs.map((pb) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: PBIcon(color: sapphireLight, label: pb.pb.name),
    )).toList();

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: routinePreviewType != RoutinePreviewType.ai ? sapphireDark80 : null,
          gradient: routinePreviewType == RoutinePreviewType.ai ? LinearGradient(
            colors: [
              Colors.blue.shade900.withOpacity(0.3),
              Colors.green.shade900.withOpacity(0.3)
            ],
            begin: Alignment.topLeft, // Gradient starts from top-left
            end: Alignment.bottomRight, // Gradient ends at bottom-right
          ) : null,
        borderRadius: BorderRadius.circular(5.0),
        border: pbs.isNotEmpty ? Border.all(color: sapphireLight, width: 2) : null, // Border color
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
