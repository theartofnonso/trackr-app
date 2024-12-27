import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../utils/general_utils.dart';

class KbRepsScreen extends StatelessWidget {
  const KbRepsScreen({super.key});

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
                      'images/man_dumbbell.jpg',
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
                            Text("Reps and Ranges: Mastering the Basics for Optimal Training",
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
                        "Rep ranges refer to the number of repetitions performed during a set of an exercise.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        "The choice of rep range plays a significant role in determining the training effect and adaptations.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      _ListItem(
                          title: "Low Rep Range (1-5 reps)",
                          subtitle: "Strength",
                          description:
                              "Low rep ranges with heavy weights primarily target neural adaptations, improving the efficiency of the nervous system in recruiting motor units."),
                      _ListItem(
                          title: "Moderate Rep Range (6-12 reps)",
                          subtitle: "Hypertrophy (Muscle Growth)",
                          description:
                              "This rep range induces muscle hypertrophy by creating metabolic stress and cellular fatigue. It involves a balance between lifting moderate weights for a moderate number of reps, promoting both muscle size and strength."),
                      _ListItem(
                          title: "High Rep Range (15+ reps)",
                          subtitle: "Muscular Endurance",
                          description:
                              "High-repetition training targets endurance and increases the muscular capacity to sustain activity over an extended period.")
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
      Text(
        subtitle.toUpperCase(),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDarkMode ? Colors.white70 : Colors.grey.shade200),
      )
    ]);
  }
}
