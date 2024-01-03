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
              color: MaterialStateColor.resolveWith((states) => tealBlueDark),
              avatar: const FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
              label: Text(pb.name,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              labelPadding: const EdgeInsets.only(left: 4),
              side: const BorderSide(width: 0, color: Colors.transparent),
            ))
        .toList();

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
        children: [child, if (pbs != null) Row(mainAxisAlignment: MainAxisAlignment.center, children: pbs)],
      ),
    );
  }
}
