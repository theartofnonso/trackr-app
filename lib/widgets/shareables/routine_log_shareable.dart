import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';
import '../chart/muscle_group_family_chart.dart';

GlobalKey routineLogShareableKey = GlobalKey();

class RoutineLogShareable extends StatelessWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;

  const RoutineLogShareable({super.key, required this.log, required this.frequencyData});

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = log.exerciseLogs
        .mapIndexed(((index, exerciseLog) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                  text: TextSpan(
                      text: exerciseLog.exercise.name,
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                      children: [
                    const TextSpan(text: " "),
                    TextSpan(
                        text:
                            "x${exerciseLog.sets.length} ${pluralize(word: "Set", count: exerciseLog.sets.length)} ${index == 2 ? "+ ${log.exerciseLogs.length}" : ""}",
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 12))
                  ])),
            )))
        .take(3)
        .toList();

    return RepaintBoundary(
      key: routineLogShareableKey,
      child: Container(
        height: exerciseLogs.length > 2 ? 800 : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(log.name,
                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                subtitle: Row(
                  children: [
                    const Icon(
                      Icons.date_range_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 1),
                    Text(log.createdAt.formattedDayAndMonth(),
                        style: GoogleFonts.ubuntu(
                            color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 1),
                    Text(log.duration().hmsAnalog(),
                        style: GoogleFonts.ubuntu(
                            color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                  ],
                ),
              ),
              MuscleGroupFamilyChart(frequencyData: frequencyData),
              ...exerciseLogs,
              Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'images/trkr.png',
                    fit: BoxFit.contain,
                    height: 8, // Adjust the height as needed
                  )),
            ]),
      ),
    );
  }
}
