import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../utils/general_utils.dart';
import '../../utils/readiness_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

enum IntensityScale { lowToHigh, highToLow }

class ReadinessScreen extends StatefulWidget {
  static const routeName = '/recovery_screen';

  const ReadinessScreen({super.key});

  @override
  State<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends State<ReadinessScreen> {
  int _painRating = 0;
  int _sorenessRating = 0;
  int _fatigueRating = 0;

  @override
  Widget build(BuildContext context) {

    final readinessScore =
        calculateReadinessScore(pain: _painRating, fatigue: _fatigueRating, soreness: _sorenessRating);

    final readinessDescription = getTrainingGuidance(readinessScore: readinessScore);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
          onPressed: context.pop,
        ),
        title: Text("Readiness Check"),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeGradient(context: context)),
        child: SafeArea(
          minimum: EdgeInsets.all(10),
          bottom: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 20, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(alignment: Alignment.center, children: [
                    ReadinessMonitor(value: readinessScore, width: 100, height: 100, strokeWidth: 6),
                    Text("$readinessScore",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ))
                  ]),
                  Expanded(
                    child: Text(readinessDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 100),
                children: [
                  _MetricRatingSlider(
                    title: "Pain or Injury",
                    description:
                        "Acute pain or injury risk is a critical safety concern; if present, training may need to be skipped or heavily modified.",
                    ratings: _painOrInjuryScale,
                    onSelectRating: (int rating) {
                      setState(() {
                        _painRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _MetricRatingSlider(
                    title: "Muscle Soreness",
                    description:
                        "Excessive soreness can limit range of motion and performance. It may signal the need for active recovery or a lighter session.",
                    ratings: _muscleSorenessScale,
                    onSelectRating: (int rating) {
                      setState(() {
                        _sorenessRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _MetricRatingSlider(
                    title: "Perceived Fatigue",
                    description:
                        "Feeling exhausted (physically or mentally) can affect form, increase injury risk, and reduce workout effectiveness.",
                    ratings: _perceivedFatigueScale,
                    onSelectRating: (int rating) {
                      setState(() {
                        _fatigueRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SafeArea(
                    minimum: EdgeInsets.all(10),
                    child: SizedBox(
                        width: double.infinity,
                        child: OpacityButtonWidget(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          buttonColor: lowToHighIntensityColor(readinessScore / 100),
                          label: "Start Training",
                          onPressed: () {
                            context.pop(readinessScore);
                          },
                        )),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class _MetricRatingSlider extends StatefulWidget {
  final Map<int, String> ratings;
  final void Function(int rating) onSelectRating;
  final String title;
  final String description;

  const _MetricRatingSlider(
      {required this.ratings,
      required this.onSelectRating,
      required this.title,
      required this.description});

  @override
  State<_MetricRatingSlider> createState() => _MetricRatingSliderState();
}

class _MetricRatingSliderState extends State<_MetricRatingSlider> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final color = highToLowIntensityColor(_rating / 10);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? color.withValues(alpha: 0.1) : color, borderRadius: BorderRadius.circular(5)),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(widget.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
          Text(
            _ratingDescription(_rating),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black12 : Colors.white38,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Slider(value: _rating, onChanged: onChanged, min: 0, max: 9, divisions: 9, thumbColor: color)),
        ],
      ),
    );
  }

  void onChanged(double value) {
    HapticFeedback.heavyImpact();

    setState(() {
      _rating = value;
    });

    final absoluteRating = _rating.floor();
    widget.onSelectRating(absoluteRating);
  }

  String _ratingDescription(double rating) {
    final absoluteRating = rating.floor();

    return widget.ratings[absoluteRating]!;
  }
}

/// Pain or Injury
Map<int, String> _painOrInjuryScale = {
  1: "😌 No pain or discomfort",
  2: "🙂 Slight twinge, easily ignored",
  3: "😊 Minor ache, not impacting movement",
  4: "😐 Noticeable pain, proceed with caution",
  5: "😕 Moderate pain, consider modifications",
  6: "😟 Significant pain, limit intensity",
  7: "😣 Severe pain, training at risk",
  8: "😫 Very severe pain, high injury risk",
  9: "🤕 Extreme pain, likely skip session",
  10: "🚑 Excruciating pain, stop immediately"
};

/// Perceived Fatigue
Map<int, String> _perceivedFatigueScale = {
  1: "😌 Fully refreshed, no fatigue",
  2: "🙂 Slight tiredness, not an issue",
  3: "😊 Mild fatigue, still performing well",
  4: "😐 Noticeable tiredness, but manageable",
  5: "😶 Moderate fatigue, may need breaks",
  6: "😑 Feeling worn, pace is harder to sustain",
  7: "😴 Very tired, performance dropping quickly",
  8: "🥱 Struggling to keep going",
  9: "😫 Exhausted, near physical/mental limit",
  10: "💤 Completely drained, no capacity left"
};

/// Muscle Soreness (DOMS)
Map<int, String> _muscleSorenessScale = {
  1: "😌 No soreness, muscles feel fresh",
  2: "🙂 Slight tenderness, barely noticeable",
  3: "😊 Mild tightness, easy to move through",
  4: "😐 Some soreness, but not limiting",
  5: "😶 Moderate soreness, performance impacted",
  6: "😑 Achy muscles, need extended warm-up",
  7: "😬 High soreness, range of motion reduced",
  8: "😣 Very sore, significantly limiting",
  9: "🥵 Intense DOMS, serious hindrance",
  10: "💀 Severe soreness, movement is very painful"
};

class ReadinessMonitor extends StatelessWidget {
  final int value;
  final double width;
  final double height;
  final double strokeWidth;

  const ReadinessMonitor({super.key,
    this.value = 0,
    required this.width,
    required this.height,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return SizedBox(
      width: height,
      height: width,
      child: CircularProgressIndicator(
        value: value / 100,
        strokeWidth: strokeWidth,
        backgroundColor: isDarkMode ? Colors.black12 : Colors.grey.shade200,
        strokeCap: StrokeCap.butt,
        valueColor: AlwaysStoppedAnimation<Color>(lowToHighIntensityColor(value / 100)),
      ),
    );
  }
}
