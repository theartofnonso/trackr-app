import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/general_utils.dart';
import '../../utils/readiness_utils.dart';

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
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final readinessScore = calculateReadinessScore(
        pain: _painRating, fatigue: _fatigueRating, soreness: _sorenessRating);

    final readinessDescription = getTrainingGuidance(readinessScore: readinessScore);

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeGradient(context: context)),
        child: SafeArea(
          minimum: EdgeInsets.all(10),
          bottom: false,
          child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 100),
              child: Column(spacing: 20, children: [
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
                _MetricRatingSlider(
                  title: "Perceived Fatigue",
                  description:
                      "Excessive soreness can limit range of motion and performance. It may signal the need for active recovery or a lighter session.",
                  ratings: _perceivedFatigueScale,
                  onSelectRating: (int rating) {
                    setState(() {
                      _fatigueRating = rating;
                    });
                  },
                )
              ])),
        ),
      ),
    );
  }
}

class _MetricRatingSlider extends StatefulWidget {
  final IntensityScale intensityScale;
  final Map<int, String> ratings;
  final void Function(int rating) onSelectRating;
  final String title;
  final String description;

  const _MetricRatingSlider(
      {this.intensityScale = IntensityScale.highToLow,
      required this.ratings,
      required this.onSelectRating,
      required this.title,
      required this.description});

  @override
  State<_MetricRatingSlider> createState() => _MetricRatingSliderState();
}

class _MetricRatingSliderState extends State<_MetricRatingSlider> {
  double _rating = 1;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final color = switch (widget.intensityScale) {
      IntensityScale.lowToHigh => lowToHighIntensityColor(_rating / 10),
      IntensityScale.highToLow => highToLowIntensityColor(_rating / 10),
    };
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
              child: Slider(value: _rating, onChanged: onChanged, min: 1, max: 10, divisions: 9, thumbColor: color)),
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
