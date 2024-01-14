import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../app_constants.dart';
import 'pb_icon.dart';

class Pbs extends StatelessWidget {
  final List<PBDto> pbs;

  const Pbs({super.key, required this.pbs});

  @override
  Widget build(BuildContext context) {
    final pbsByExercises = groupBy(pbs, (pb) => pb.exercise);

    List<Widget> widgets = [];

    for (final pbAndExercise in pbsByExercises.entries) {
      final pbs = pbAndExercise.value.map((pb) => pb.pb).toSet();
      final pbsWidgets = pbs
          .map((pb) => Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: PBIcon(color: tealBlueLight, label: pb.name),
              ))
          .toList();
      final pb = Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: tealBlueLight, // Container color
          borderRadius: BorderRadius.circular(5.0),
          // Radius for rounded corners
        ),
        //width: 300,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pbAndExercise.key.name,
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: pbsWidgets)
        ]),
      );
      widgets.add(pb);
    }

    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: widgets));
  }
}
