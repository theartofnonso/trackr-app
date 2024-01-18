import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/pb_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../app_constants.dart';
import '../../dtos/pb_dto.dart';
import '../../enums/exercise_type_enums.dart';

GlobalKey routineLogShareableThreeKey = GlobalKey();

class RoutineLogShareableThree extends StatelessWidget {
  final GlobalKey globalKey;
  final SetDto set;
  final PBDto pbDto;

  const RoutineLogShareableThree({super.key, required this.globalKey, required this.set, required this.pbDto});

  @override
  Widget build(BuildContext context) {

    String value = "";

    if(pbDto.exercise.type == ExerciseType.duration) {
      value = Duration(milliseconds: set.value1.toInt()).hmsAnalog();
    } else if(pbDto.exercise.type == ExerciseType.weights) {
      if(pbDto.pb == PBType.weight) {
        value = "${set.value1.toDouble()}${weightLabel().toUpperCase()}";
      } else {
        value = "${set.value1}${weightLabel().toUpperCase()} x ${set.value2}";
      }

    }

    return RepaintBoundary(
      key: globalKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: tealBlueDark,
        width: MediaQuery.of(context).size.width - 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green.shade700, size: 14),
            const SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green.shade500, size: 16),
            const SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green.shade700, size: 14)
          ]),
          const SizedBox(height: 30),
          Text(value, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(pbDto.exercise.name,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(pbDto.pb.description,
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 40),
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
