import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../utils/general_utils.dart';

class KbVolumeScreen extends StatelessWidget {
  const KbVolumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topCenter, children: [
      Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(children: [
                    Positioned.fill(
                        child: Image.asset(
                      'images/orange_dumbbells.jpg',
                      fit: BoxFit.cover,
                    )),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            sapphireDark.withValues(alpha: 0.4),
                            sapphireDark.withValues(alpha: 0.8),
                            sapphireDark,
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Volume vs. Intensity: Unlocking the Key to Effective Training",
                                style:
                                    GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 22)),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
                            onPressed: context.pop,
                          )
                        ]),
                      ),
                    )
                  ]),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    spacing: 18,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Volume refers to the total amount of work performed during a workout, typically calculated as:",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        "Volume = Sets × Reps × Weight",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      _ListItem(
                          title: "Why Volume Matters",
                          subtitle:
                              "Volume plays a critical role in progressive overload, the principle of gradually increasing stress on the body to promote adaptation.",
                          description:
                              "Higher training volumes are generally associated with greater muscle growth, provided recovery and nutrition are adequate. However, optimal volume varies depending on factors such as training experience, goals, and individual recovery capacity."),
                      const SizedBox(height: 2),
                      Text(
                        "Types of Volume",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      _ListItem(
                          title: "Per-Session Volume",
                          subtitle: "The total volume for a single workout.",
                          description: "This helps gauge the intensity of individual sessions"),
                      _ListItem(
                          title: "Weekly Volume",
                          subtitle: "The cumulative volume across all training sessions in a week.",
                          description: "This is a key metric for long-term progress."),
                      _ListItem(
                          title: "Per-Muscle Volume",
                          subtitle: "The volume targeting specific muscle groups.",
                          description:
                              "Research suggests that working a muscle with 10–20 sets per week is ideal for most people aiming for hypertrophy."),
                      const SizedBox(height: 2),
                      Text(
                        "Balancing Volume and Recovery",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "While increasing volume can enhance gains, more isn’t always better. Excessive volume can lead to overtraining, fatigue, and injury. Striking the right balance requires monitoring recovery, sleep, and performance metrics.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      _ListItem(
                          title: "Start Low, Build Gradually",
                          subtitle: "",
                          description:
                              "Beginners should begin with lower volumes and increase as their recovery and capacity improve"),
                      _ListItem(
                          title: "Monitor Fatigue",
                          subtitle: "",
                          description:
                              "If performance declines or recovery feels insufficient, consider reducing volume temporarily."),
                      _ListItem(
                          title: "Prioritize Quality",
                          subtitle: "",
                          description:
                              "Focus on proper form and effective reps (those close to failure) rather than just increasing the numbers."),
                      _ListItem(
                          title: "Track Progress",
                          subtitle: "",
                          description:
                              "Use a training log to measure volume and adjust based on your goals and results."),
                      Text(
                        "While increasing volume can enhance gains, more isn’t always better. Excessive volume can lead to overtraining, fatigue, and injury. Striking the right balance requires monitoring recovery, sleep, and performance metrics.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;

  const _ListItem({required this.title, required this.subtitle, required this.description});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 20),
      ),
      const SizedBox(height: 4),
      if (subtitle.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
          ],
        ),
      Text(
        description,
        style:
            Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDarkMode ? Colors.white70 : Colors.grey.shade200),
      )
    ]);
  }
}
