import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';

class RoutineMuscleGroupFrequencyChart extends StatelessWidget {
  final Map<MuscleGroupFamily, double> frequencyData;
  final bool minimized;

  const RoutineMuscleGroupFrequencyChart({super.key, required this.frequencyData, this.minimized = false});

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
    final unscaledFrequency = frequency * 8;

    final remainder = 8 - unscaledFrequency.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), border: Border.all(color: sapphireLighter, width: 2.0)),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(muscleGroupFamily.name.toUpperCase(),
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Colors.white70, fontSize: 12)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: LinearProgressIndicator(
                    value: frequency,
                    backgroundColor: Colors.white60.withOpacity(0.1),
                    color: Colors.white,
                    minHeight: 25,
                    borderRadius: BorderRadius.circular(3.0), // Border r
                  ),
                ),
              ),
              if (remainder > 0)
                Text("$remainder left", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class TextWithOutline extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final Color outlineColor;
  final double outlineWidth;

  const TextWithOutline({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.textColor,
    required this.outlineColor,
    this.outlineWidth = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outlineColor,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
