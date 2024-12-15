import 'package:flutter/material.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../enums/muscle_group_enums.dart';

class MuscleGroupFamilyFrequencyChart extends StatelessWidget {
  final Map<MuscleGroupFamily, double> frequencyData;
  final bool minimized;

  const MuscleGroupFamilyFrequencyChart(
      {super.key, required this.frequencyData, this.minimized = false});

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
    final entries = (minimized ? frequencyData.entries.take(3) : frequencyData.entries).toList();

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final entry = entries[index];

          return _LinearBar(muscleGroupFamily: entry.key, frequency: entry.value);
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 8);
        },
        itemCount: entries.length);
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

    return Container(
      padding: const EdgeInsets.only(top: 10, right: 6, left: 8, bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
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
          const SizedBox(width: 10),
          SizedBox(
            width: 35,
            child: Text("${(frequency * 100).round()}%", style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
