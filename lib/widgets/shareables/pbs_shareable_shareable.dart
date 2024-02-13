import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/pb_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../dtos/pb_dto.dart';

GlobalKey pbsShareableKey = GlobalKey();

class PBsShareable extends StatelessWidget {
  final GlobalKey globalKey;
  final SetDto set;
  final PBDto pbDto;

  const PBsShareable({super.key, required this.globalKey, required this.set, required this.pbDto});

  @override
  Widget build(BuildContext context) {

    String? value;

    if(withDurationOnly(type: pbDto.exercise.type)) {
      value = Duration(milliseconds: set.durationValue()).hmsAnalog();
    } else if(withWeightsOnly(type: pbDto.exercise.type)) {
      if(pbDto.pb == PBType.weight) {
        value = "${set.weightValue()}${weightLabel().toUpperCase()}";
      } else {
        value = "${set.weightValue()}${weightLabel().toUpperCase()} x ${set.repsValue()}";
      }

    }

    return RepaintBoundary(
      key: globalKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        color: sapphireDark,
        width: MediaQuery.of(context).size.width - 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
           const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
            SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.solidStar, color: vibrantGreen, size: 16),
            SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14)
          ]),
          value != null ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(value, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
          ) : const SizedBox(height: 10),
          Text(pbDto.exercise.name,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(pbDto.pb.description,
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Image.asset(
            'images/trackr.png',
            fit: BoxFit.contain,
            height: 8, // Adjust the height as needed
          ),
        ]),
      ),
    );
  }
}
