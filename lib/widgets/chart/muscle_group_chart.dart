import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';

class MuscleGroupChart extends StatelessWidget {
  final Map<MuscleGroup, double> frequencyData;
  final bool minimized;

  const MuscleGroupChart({super.key, required this.frequencyData, this.minimized = false});

  @override
  Widget build(BuildContext context) {
    return _HorizontalBarChart(
      frequencyData: frequencyData,
      minimized: minimized,
    );
  }
}

class _HorizontalBarChart extends StatelessWidget {
  final bool minimized;
  final Map<MuscleGroup, double> frequencyData;

  const _HorizontalBarChart({required this.frequencyData, required this.minimized});

  @override
  Widget build(BuildContext context) {
    final children =
        frequencyData.entries.map((entry) => _LinearBar(muscleGroup: entry.key, frequency: entry.value));

    final count = minimized ? children.take(3) : children;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: count.toList());
  }
}

class _LinearBar extends StatelessWidget {
  final MuscleGroup muscleGroup;
  final double frequency;

  const _LinearBar({required this.muscleGroup, required this.frequency});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: sapphireDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    LinearProgressIndicator(
                      value: frequency,
                      backgroundColor: Colors.white10,
                      color: Colors.white,
                      minHeight: 25,
                      borderRadius: BorderRadius.circular(3.0), // Border r
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(muscleGroup.name.toUpperCase(),
                          style:
                              GoogleFonts.ubuntu(fontWeight: FontWeight.w700, color: sapphireDark, fontSize: 12)),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 32,
                child: Text("${(frequency * 100).round()}%",
                    style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
