import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_widget.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';

class MuscleGroupFamilyFrequencyChart extends StatelessWidget {
  final Map<MuscleGroupFamily, double> frequencyData;
  final bool minimized;

  const MuscleGroupFamilyFrequencyChart({super.key, required this.frequencyData, this.minimized = false});

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
  final Map<MuscleGroupFamily, double> frequencyData;

  const _HorizontalBarChart({required this.frequencyData, required this.minimized});

  @override
  Widget build(BuildContext context) {
    List<Widget> children =
        frequencyData.entries.map((entry) => _LinearBar(muscleGroupFamily: entry.key, frequency: entry.value)).toList();

    if (children.isEmpty) {
      print(children);
      final emptyState = {
        MuscleGroupFamily.chest: 0.0,
        MuscleGroupFamily.back: 0.0,
        MuscleGroupFamily.legs: 0.0,
      }.entries.map((entry) => _LinearBar(muscleGroupFamily: entry.key, frequency: entry.value));
      children.addAll(emptyState);
    }

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
    final unscaledFrequency = frequency * 8;

    final remainder = 8 - unscaledFrequency.toInt();

    final bar = Container(
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
                  backgroundColor: sapphireDark,
                  color: Colors.white,
                  minHeight: 25,
                  borderRadius: BorderRadius.circular(3.0), // Border r
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(muscleGroupFamily.name.toUpperCase(),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: sapphireDark, fontSize: 12)),
                )
              ],
            ),
          ),
          if (remainder > 0)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                SizedBox(
                    width: 32,
                    child: Text("$remainder left", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12))),
              ],
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frequency > 0 ? bar : GradientWidget(child: bar),
        const SizedBox(height: 8),
      ],
    );
  }
}
