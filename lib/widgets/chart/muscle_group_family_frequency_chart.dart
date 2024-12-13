import 'package:flutter/material.dart';
import 'package:tracker_app/utils/general_utils.dart';

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
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final unscaledFrequency = frequency * 8;

    final remainder = 8 - unscaledFrequency.toInt();

    final bar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? sapphireDark80 : Colors.grey.shade100,
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
                  backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade400,
                  color: muscleFamilyFrequencyColor(value: frequency, isDarkMode: isDarkMode),
                  minHeight: 25,
                  borderRadius: BorderRadius.circular(3.0), // Border r
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(muscleGroupFamily.name.toUpperCase(),
                      style: isDarkMode
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                )
              ],
            ),
          ),
          if (remainder > 0)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                SizedBox(width: 32, child: Text("$remainder left", style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bar,
        const SizedBox(height: 8),
      ],
    );
  }
}
