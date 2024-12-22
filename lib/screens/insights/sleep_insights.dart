import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../utils/general_utils.dart';
import '../../widgets/dividers/label_divider.dart';

class SleepInsights extends StatefulWidget {
  const SleepInsights({super.key});

  @override
  State<SleepInsights> createState() => _SleepInsightsState();
}

class _SleepInsightsState extends State<SleepInsights> {
  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

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
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w400, height: 1.8, fontSize: 16),
                ),
                const SizedBox(height: 10),
                LabelDivider(
                  label: "Sleep breakdown".toUpperCase(),
                  labelColor: isDarkMode ? Colors.white70 : Colors.black,
                  dividerColor: sapphireLighter,
                  fontSize: 14,
                ),
              ],
            )),
      ),
    );
  }

  void calculateSleep() async {
    final dff = await calculateSleepDuration();
  }

  @override
  void initState() {
    super.initState();
    calculateSleep();
  }
}
