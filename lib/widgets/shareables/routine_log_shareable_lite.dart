import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/string_utils.dart';
import '../chart/muscle_group_family_frequency_chart.dart';
import '../routine/preview/date_duration_pb.dart';

GlobalKey routineLogGlobalKey = GlobalKey();

class RoutineLogShareableLite extends StatelessWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;
  final int pbs;
  final Image? image;

  const RoutineLogShareableLite({super.key, required this.log, required this.frequencyData, this.pbs = 0, this.image});

  @override
  Widget build(BuildContext context) {
    final imageFile = image;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: RepaintBoundary(
          key: routineLogGlobalKey,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: sapphireLighter),
              borderRadius: BorderRadius.circular(20),
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
            child: Stack(alignment: Alignment.center, children: [
              if (imageFile != null)
                Positioned.fill(
                    child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      sapphireDark.withOpacity(0.4),
                      sapphireDark,
                    ],
                  )),
                )),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: imageFile != null ? MainAxisAlignment.end : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(log.name,
                            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                        subtitle: DateDurationPBWidget(dateTime: log.createdAt, duration: log.duration(), pbs: pbs),
                      ),
                      RichText(
                          text: TextSpan(
                              text:
                                  "${log.exerciseLogs.length} ${pluralize(word: "Exercise", count: log.exerciseLogs.length)}",
                              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                              children: [
                            const TextSpan(text: " "),
                            TextSpan(
                                text:
                                    "x${log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length)} ${pluralize(word: "Set", count: log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length))}",
                                style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 12)),
                          ])),
                      const SizedBox(height: 8),
                      MuscleGroupFamilyFrequencyChart(frequencyData: frequencyData),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Image.asset(
                              'images/trkr.png',
                              fit: BoxFit.contain,
                              height: 8, // Adjust the height as needed
                            ),
                          )
                        ],
                      ),
                    ]),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
