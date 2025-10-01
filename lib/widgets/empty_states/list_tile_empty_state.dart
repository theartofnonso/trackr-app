import 'package:flutter/material.dart';

import '../../colors.dart';

class ListTileEmptyState extends StatelessWidget {
  const ListTileEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 160,
            height: 10,
            decoration: BoxDecoration(
              color: isDarkMode ? darkSurfaceContainer : Colors.grey.shade600,
              borderRadius: BorderRadius.circular(radiusMD),
            )),
        const SizedBox(height: 5),
        Container(
            width: 100,
            height: 10,
            decoration: BoxDecoration(
              color: isDarkMode ? darkSurfaceContainer : Colors.grey.shade600,
            ))
      ],
    );
  }
}
