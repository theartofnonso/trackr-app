import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/string_utils.dart';
import '../chart/muscle_group_family_chart.dart';

GlobalKey routineLogShareableLiteKey = GlobalKey();

class RoutineLogShareableLite extends StatelessWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;
  final Image? image;

  const RoutineLogShareableLite({super.key, required this.log, required this.frequencyData, this.image});

  @override
  Widget build(BuildContext context) {
    final imageFile = image;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RepaintBoundary(
        key: routineLogShareableLiteKey,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            decoration: BoxDecoration(
              image: imageFile != null
                  ? DecorationImage(
                      image: imageFile.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )
                  : null,
              color: sapphireDark,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
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
            child: Stack(alignment: Alignment.center, fit: StackFit.expand, children: [
              if (imageFile != null)
                Positioned.fill(
                    child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                            style:
                                GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.date_range_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 1),
                            Text(log.createdAt.formattedDayAndMonth(),
                                style: GoogleFonts.montserrat(
                                    color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.access_time_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 1),
                            Text(log.duration().hmsAnalog(),
                                style: GoogleFonts.montserrat(
                                    color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                          ],
                        ),
                      ),
                      MuscleGroupFamilyChart(frequencyData: frequencyData),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                              text: TextSpan(
                                  text:
                                      "${log.exerciseLogs.length} ${pluralize(word: "Exercise", count: log.exerciseLogs.length)}",
                                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                                  children: [
                                const TextSpan(text: " "),
                                TextSpan(
                                    text:
                                        "x${log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length)} ${pluralize(word: "Set", count: log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length))}",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 12))
                              ])),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Image.asset(
                              'images/trackr.png',
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
