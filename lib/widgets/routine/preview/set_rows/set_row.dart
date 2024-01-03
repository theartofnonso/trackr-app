import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_constants.dart';
import '../exercise_log_widget.dart';

class SetRow extends StatelessWidget {

  final EdgeInsets? margin;
  final PBViewModel? pbViewModel;
  final Widget child;

  const SetRow({super.key, this.margin, this.pbViewModel, required this.child});

  @override
  Widget build(BuildContext context) {
    final pb = pbViewModel;

    final pbs = pb?.pbs
        .map((pb) => Chip(
      avatar: const FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
      label: Text(pb.name,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      labelPadding: const EdgeInsets.only(left: 4),
      side: const BorderSide(width: 0, color: Colors.transparent),
    ))
        .toList();

    return Container(
      margin: pbViewModel == null ? margin : null,
      decoration: BoxDecoration(
        color: pbViewModel != null ? Colors.transparent : tealBlueLight, // Container color
        borderRadius: pbViewModel != null
            ? const BorderRadius.only(
            topLeft: Radius.circular(5), // 20 is just an example value for the radius
            topRight: Radius.circular(5))
            : BorderRadius.circular(5.0),
        // Radius for rounded corners
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          child,
          if (pbs != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Colors.transparent, // Background color
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16), // 20 is just an example value for the radius
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  left: BorderSide(
                    color: Colors.green, // Color of the left border
                    width: 2, // Width of the left border
                  ),
                  right: BorderSide(
                    color: Colors.green, // Color of the right border
                    width: 2, // Width of the right border
                  ),
                  bottom: BorderSide(
                    color: Colors.green, // Color of the bottom border
                    width: 2, // Width of the bottom border
                  ),
                  // The top border is omitted
                ),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: pbs),
              // Other properties of Container like height, width, child, etc.
            )
        ],
      ),
    );
  }
}
