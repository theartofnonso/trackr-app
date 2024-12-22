import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/pb_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../dtos/pb_dto.dart';
import '../../dtos/set_dtos/duration_set_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';

GlobalKey pbsGlobalKey = GlobalKey();

class PBsShareable extends StatelessWidget {
  final GlobalKey globalKey;
  final SetDto set;
  final PBDto pbDto;
  final Image? image;

  const PBsShareable({super.key, required this.globalKey, required this.set, required this.pbDto, this.image});

  @override
  Widget build(BuildContext context) {
    String? value;

    if (withDurationOnly(type: pbDto.exercise.type)) {
      value = (set as DurationSetDto).duration.hmsAnalog();
    } else if (withWeightsOnly(type: pbDto.exercise.type)) {
      if (pbDto.pb == PBType.weight) {
        value = "${(set as WeightAndRepsSetDto).weight}${weightLabel().toUpperCase()}";
      } else {
        final weightAndRepsSet = (set as WeightAndRepsSetDto);
        value = "${weightAndRepsSet.weight}${weightLabel().toUpperCase()} x ${weightAndRepsSet.reps}";
      }
    }

    final imageFile = image;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: RepaintBoundary(
          key: globalKey,
          child: Container(
            decoration: BoxDecoration(
              image: imageFile != null
                  ? DecorationImage(
                      image: imageFile.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )
                  : null,
              gradient: imageFile == null
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        sapphireDark80,
                        sapphireDark,
                      ],
                    )
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                if (imageFile != null)
                  Positioned.fill(
                      child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        sapphireDark.withValues(alpha: 0.4),
                        sapphireDark,
                      ],
                    )),
                  )),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14),
                        SizedBox(width: 8),
                        FaIcon(FontAwesomeIcons.solidStar, color: vibrantGreen, size: 16),
                        SizedBox(width: 8),
                        FaIcon(FontAwesomeIcons.solidStar, color: Colors.green, size: 14)
                      ]),
                      value != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(value,
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                            )
                          : const SizedBox(height: 20),
                      Text(pbDto.exercise.name,
                          style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(pbDto.pb.description,
                          style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 30),
                    ]),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0, bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Image.asset(
                          'images/trkr.png',
                          fit: BoxFit.contain,
                          height: 8, // Adjust the height as needed
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
