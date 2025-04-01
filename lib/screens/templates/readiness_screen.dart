import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/dtos/daily_readiness.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../utils/general_utils.dart';
import '../../utils/readiness_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

class ReadinessScreen extends StatefulWidget {
  static const routeName = '/recovery_screen';

  final List<MuscleGroup> muscleGroups;

  const ReadinessScreen({super.key, this.muscleGroups = const []});

  @override
  State<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends State<ReadinessScreen> {
  int _sorenessRating = ReadinessEnum.minPositive.value;
  int _fatigueRating = ReadinessEnum.minPositive.value;
  int _sleepRating = ReadinessEnum.maxPositive.value;

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final readinessScore = calculateReadinessScore(fatigue: _fatigueRating, soreness: _sorenessRating);

    final muscleGroups = widget.muscleGroups.map((muscleGroup) => muscleGroup.displayName.toLowerCase()).toList();

    final muscleGroupNames = joinWithAnd(items: muscleGroups);

    final dailyReadiness =
        DailyReadiness(perceivedFatigue: _fatigueRating, muscleSoreness: _sorenessRating, sleepDuration: _sleepRating);

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
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 100),
                children: [
                  Text(
                      "A readiness check helps you assess how prepared you are for today’s training session. Based on how you rate yourself, we’ll generate a score that guides you in adjusting your training intensity—helping you train smarter, avoid overtraining, and reduce the risk of injury.",
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 14, height: 1.5, color: isDarkMode ? Colors.white70 : Colors.black)),
                  const SizedBox(height: 20),
                  _MetricRatingSlider(
                    title: "Muscle Soreness",
                    description:
                        "Excessive soreness${muscleGroupNames.isNotEmpty ? " in your $muscleGroupNames " : " "}can limit range of motion and performance. It may signal the need for active recovery or a lighter session.",
                    ratings: muscleSorenessScale,
                    onSelectRating: (int rating) {
                      setState(() {
                        _sorenessRating = rating;
                      });
                    },
                    defaultRating: _sorenessRating,
                  ),
                  const SizedBox(height: 20),
                  _MetricRatingSlider(
                    title: "Perceived Fatigue",
                    description:
                        "Feeling exhausted (physically or mentally) can affect form, increase injury risk, and reduce workout effectiveness.",
                    ratings: perceivedFatigueScale,
                    onSelectRating: (int rating) {
                      setState(() {
                        _fatigueRating = rating;
                      });
                    },
                    defaultRating: _fatigueRating,
                  ),
                  const SizedBox(height: 20),
                  _MetricRatingSlider(
                    title: "Sleep Duration",
                    description:
                        "Inadequate sleep limits muscle recovery, reduces mental focus, and can elevate injury risk—ultimately undermining performance and progress.",
                    ratings: sleepDurationScale,
                    highToLowIntensity: false,
                    onSelectRating: (int rating) {
                      setState(() {
                        _sleepRating = rating;
                      });
                    },
                    defaultRating: _sleepRating,
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
                            context.pop(dailyReadiness);
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
  final bool highToLowIntensity;
  final int defaultRating;

  const _MetricRatingSlider(
      {required this.ratings,
      required this.onSelectRating,
      required this.title,
      required this.description,
      this.highToLowIntensity = true,
      required this.defaultRating});

  @override
  State<_MetricRatingSlider> createState() => _MetricRatingSliderState();
}

class _MetricRatingSliderState extends State<_MetricRatingSlider> {
  double _rating = 1;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final color =
        widget.highToLowIntensity ? highToLowIntensityColor(_rating / 5) : lowToHighIntensityColor(_rating / 5);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? color.withValues(alpha: 0.08) : color, borderRadius: BorderRadius.circular(5)),
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
              child: Slider(value: _rating, onChanged: onChanged, min: 1, max: 5, divisions: 4, thumbColor: color)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _rating = widget.defaultRating.toDouble();
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

class ReadinessMonitor extends StatelessWidget {
  final int value;
  final double width;
  final double height;
  final double strokeWidth;

  const ReadinessMonitor({
    super.key,
    this.value = 100,
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
