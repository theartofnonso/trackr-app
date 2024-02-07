import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';

class RoutineMuscleGroupSplitChart extends StatelessWidget {
  final Map<MuscleGroupFamily, double> frequencyData;
  final bool minimized;

  const RoutineMuscleGroupSplitChart({super.key, required this.frequencyData, this.minimized = false});

  @override
  Widget build(BuildContext context) {
    return _HorizontalBarChart(frequencyData: frequencyData, minimized: minimized,);
  }
}

class _HorizontalBarChart extends StatelessWidget {
  final bool minimized;
  final Map<MuscleGroupFamily, double> frequencyData;

  const _HorizontalBarChart({required this.frequencyData, required this.minimized});

  @override
  Widget build(BuildContext context) {
    final children =
        frequencyData.entries.map((entry) => _LinearBar(muscleGroupFamily: entry.key, frequency: entry.value));

    final count = minimized ? children.take(3) : children;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: count.toList());
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
              color: frequency > 0 ? vibrantGreen : sapphireLight,
              minHeight: 24,
              borderRadius: BorderRadius.circular(3.0), // Border r
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: sapphireDark.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Text(muscleGroupFamily.name.toUpperCase(),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: vibrantGreen, fontSize: 12)),
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
