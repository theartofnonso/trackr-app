import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';
import '../../enums/muscle_group_enums.dart';

class RoutineMuscleGroupSplitChart extends StatelessWidget {
  final Map<MuscleGroupFamily, double> frequencyData;
  final bool showInfo;
  const RoutineMuscleGroupSplitChart({super.key, required this.frequencyData, this.showInfo = true});

  @override
  Widget build(BuildContext context) {
    return _HorizontalBarChart(frequencyData: frequencyData, showInfo: showInfo);
  }
}

class _HorizontalBarChart extends StatelessWidget {
  final bool showInfo;
  final Map<MuscleGroupFamily, double> frequencyData;

  const _HorizontalBarChart({required this.frequencyData, required this.showInfo});

  @override
  Widget build(BuildContext context) {
    final children =
    frequencyData.entries.map((entry) => _LinearBar(muscleGroupFamily: entry.key, frequency: entry.value)).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...children,
      if (showInfo)
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text("Calculations are based on primary muscle groups",
              style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 12)),
        ),
    ]);
  }
}

class _LinearBar extends StatelessWidget {
  final MuscleGroupFamily muscleGroupFamily;
  final double frequency;

  const _LinearBar({required this.muscleGroupFamily, required this.frequency});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            LinearProgressIndicator(
              value: frequency,
              backgroundColor: vibrantGreen.withOpacity(0.1),
              color: vibrantGreen,
              minHeight: 24,
              borderRadius: BorderRadius.circular(3.0), // Border r
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1, right: 14),
                  child: Text(muscleGroupFamily.name,
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 12)),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
