import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../utils/general_utils.dart';

class KbSetsScreen extends StatelessWidget {
  const KbSetsScreen({super.key});

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
                      'images/girl_standing_man_squatting.jpg',
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
                            Text("Sets: A Deep Dive into Strength Training Fundamentals",
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
                        "Sets are the number of rounds you performed for each exercise. A “set” consists of a group of repetitions (reps).",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      _ListItem(
                          title: "Working Sets",
                          subtitle: "These refer to the sets in which you perform a specific exercise with a challenging load or resistance to stimulate muscular adaptations.",
                          description:
                              "Example: 3 sets of 8 reps (3x8) with a significant amount of weight."),
                      _ListItem(
                          title: "Supersets",
                          subtitle: "These involve performing two exercises back-to-back with little to no rest between them. They can target the same muscle or different muscle groups.",
                          description:
                              "Example: Bicep curls followed immediately by tricep dips or bicep curls followed by hammer curls."),
                      _ListItem(
                          title: "Drop Sets",
                          subtitle: "These involve performing a set of an exercise until failure, then quickly reducing the weight and continuing with more repetitions until failure is reached again.",
                          description:
                              "Example: Bicep curls with a heavy dumbbell until failure, then switch to a lighter dumbbell and continue until failure.")
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
        subtitle,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 8),
      Text(
        description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDarkMode ? Colors.white70 : Colors.grey.shade800),
      )
    ]);
  }
}
