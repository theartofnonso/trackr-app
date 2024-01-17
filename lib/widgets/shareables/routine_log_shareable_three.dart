import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/pbs/pb_icon.dart';

import '../../app_constants.dart';
import '../../enums/muscle_group_enums.dart';
import '../chart/routine_muscle_group_split_chart.dart';

GlobalKey routineLogShareableThreeKey = GlobalKey();

class RoutineLogShareableThree extends StatelessWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;

  const RoutineLogShareableThree({super.key, required this.log, required this.frequencyData});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: routineLogShareableThreeKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: tealBlueDark,
        width: MediaQuery.of(context).size.width - 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
                SizedBox(width: 4),
                FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
                SizedBox(width: 4),
                FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14)
              ]),
          const SizedBox(height: 8),
          Text("100KG", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Lying Leg Curl",
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Heaviest Weight Lifted",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          const SizedBox(height: 20),
          Image.asset(
            'assets/trackr.png',
            fit: BoxFit.contain,
            height: 8, // Adjust the height as needed
          ),
        ]),
      ),
    );
  }
}
