import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/pbs/pb_icon.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../app_constants.dart';
import '../../enums/exercise_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../chart/routine_muscle_group_split_chart.dart';

GlobalKey routineLogShareableThreeKey = GlobalKey();

class RoutineLogShareableThree extends StatelessWidget {
  final GlobalKey globalKey;
  final SetDto set;
  final PBDto pbDto;

  const RoutineLogShareableThree({super.key, required this.globalKey, required this.set, required this.pbDto});

  @override
  Widget build(BuildContext context) {
    final value = pbDto.exercise.type == ExerciseType.duration
        ? Duration(milliseconds: set.value1.toInt()).hmsAnalog()
        : "${set.value1.toDouble()}${weightLabel().toUpperCase()}";

    return RepaintBoundary(
      key: globalKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: tealBlueDark,
        width: MediaQuery.of(context).size.width - 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
            SizedBox(width: 4),
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
            SizedBox(width: 4),
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14)
          ]),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(pbDto.exercise.name,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(pbDto.pb.description,
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
