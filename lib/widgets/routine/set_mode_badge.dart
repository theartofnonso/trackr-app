import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';

import '../../colors.dart';

class SetModeBadge extends StatelessWidget {
  final SetDto setDto;
  final Widget child;
  final Offset? offset;

  const SetModeBadge(
      {super.key, required this.setDto, required this.child, this.offset});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Badge(
        backgroundColor: Colors.transparent,
        alignment: Alignment.topRight,
        isLabelVisible: setDto.isWorkingSet,
        offset: offset ?? Offset(-1, 0),
        label: Container(
            width: 18,
            height: 18,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? vibrantGreen.withValues(alpha: 0.1)
                  : vibrantGreen,
              borderRadius: BorderRadius.circular(radiusXS),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.w,
                color: isDarkMode ? vibrantGreen : Colors.black,
                size: 8,
              ),
            )),
        child: child);
  }
}
