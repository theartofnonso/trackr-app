import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../colors.dart';
import '../../utils/general_utils.dart';

enum IntensityScale {
  lowToHigh, highToLow
}

class RecoveryScreen extends StatefulWidget {
  static const routeName = '/recovery_screen';

  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeGradient(context: context)),
        child: SafeArea(
          minimum: EdgeInsets.all(10),
          child: SingleChildScrollView(
              child: Column(spacing: 20, children: [
            _MetricRatingSlider(
              ratings: _painOrInjuryScale,
              onSelectRating: (int rating) {},
            ),
            _MetricRatingSlider(
              ratings: _muscleSorenessScale,
              onSelectRating: (int rating) {},
            ),
            _MetricRatingSlider(
              ratings: _perceivedFatigueScale,
              onSelectRating: (int rating) {},
            ),
            _MetricRatingSlider(
              ratings: _energyLevelsScale,
              intensityScale: IntensityScale.lowToHigh,
              onSelectRating: (int rating) {},
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

  const _MetricRatingSlider({this.intensityScale = IntensityScale.highToLow, required this.ratings, required this.onSelectRating});

  @override
  State<_MetricRatingSlider> createState() => _MetricRatingSliderState();
}

class _MetricRatingSliderState extends State<_MetricRatingSlider> {
  double _rating = 1;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final color = switch(widget.intensityScale) {
      IntensityScale.lowToHigh => lowToHighIntensityColor(_rating/10),
      IntensityScale.highToLow => highToLowIntensityColor(_rating/10),
    };
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? color.withValues(alpha: 0.1) : color,
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rate this set on a scale of 1 - 10, 1 being barely any effort and 10 being max effort",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
          const SizedBox(height: 12),
          Text(
            _ratingDescription(_rating),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Slider(
              value: _rating, onChanged: onChanged, min: 1, max: 10, divisions: 9, thumbColor: vibrantGreen),
        ],
      ),
    );
  }

  void onChanged(double value) {
    HapticFeedback.heavyImpact();

    setState(() {
      _rating = value;
    });
  }

  void onSelectRepRange() {
    Navigator.of(context).pop();
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

/// Energy Levels
Map<int, String> _energyLevelsScale = {
  1: "🐌 Zero energy, feel sluggish",
  2: "😴 Very low energy, tough to get going",
  3: "😔 Low energy, need extra motivation",
  4: "😐 Mild energy, can function but not peppy",
  5: "🙂 Decent energy, can complete normal tasks",
  6: "😊 Good energy, ready for moderate activity",
  7: "😃 High energy, feeling strong",
  8: "🤩 Very high energy, excited to push limits",
  9: "🔥 Extremely energetic, almost unstoppable",
  10: "⚡ Peak energy, bursting with vitality"
};
