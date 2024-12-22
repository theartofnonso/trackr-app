import 'package:flutter/material.dart';

import '../../utils/general_utils.dart';

class SleepInsights extends StatelessWidget {
  const SleepInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
            minimum: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'images/moon.png',
                  fit: BoxFit.contain,
                  height: 50, // Adjust the height as needed
                ),
                const SizedBox(height: 18),
                Text(
                  "Great gains start with great sleep.",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  "Sleep fuels your strength and recovery. It’s when your muscles repair and energy restores. A good night’s sleep boosts performance, improves focus, and maximizes your gains in the gym. Rest well, train harder!",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.8),
                ),
              ],
            )),
      ),
    );
  }
}
