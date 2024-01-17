import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../app_constants.dart';
import '../../enums/muscle_group_enums.dart';
import '../chart/routine_muscle_group_split_chart.dart';

GlobalKey routineLogShareableOneKey = GlobalKey();

class RoutineLogShareableOne extends StatelessWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;

  const RoutineLogShareableOne({super.key, required this.log, required this.frequencyData});

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = log.exerciseLogs
        .mapIndexed(((index, exerciseLog) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                  "${exerciseLog.exercise.name}x${exerciseLog.sets.length} ${pluralize(word: "set", count: exerciseLog.sets.length)} ${index == 2 ? "and more" : ""}",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
            )))
        .take(3)
        .toList();

    return RepaintBoundary(
      key: routineLogShareableOneKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: tealBlueDark,
        width: MediaQuery.of(context).size.width - 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(log.name,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
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
          RoutineMuscleGroupSplitChart(frequencyData: frequencyData, showInfo: false),
          const SizedBox(height: 8),
          ...exerciseLogs,
          Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/trackr.png',
                fit: BoxFit.contain,
                height: 8, // Adjust the height as needed
              )),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}
