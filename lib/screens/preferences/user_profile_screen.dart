import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/widgets/icons/user_icon_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../utils/date_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/readiness_utils.dart';
import '../../utils/workout_split_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final user = Provider.of<RoutineUserController>(context, listen: true).user;

    if (user == null) {
      return Scaffold(
          appBar: AppBar(
              leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: context.pop,
          )),
          body: _EmptyState());
    }

    final weight = user.weight;
    final height = user.height;
    final heightConversion = heightWithConversion(value: height, unit: HeightUnit.ftIn);

    final dob = user.dateOfBirth;
    final age = _calculateAge(birthDate: dob);

    final gender = user.gender;

    final trainingHistory = user.trainingHistory.isNotEmpty
        ? user.trainingHistory
        : "Tell us about your fitness journey and training goals. This helps us tailor recommendations to match your experience level.";

    final dateRange = theLastYearDateTimeRange();

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final logs = exerciseAndRoutineController.whereLogsIsWithinRange(range: dateRange).toList();

    final weeksInLastYear = generateWeeksInRange(range: dateRange).reversed.take(13).toList().reversed;

    List<String> months = [];
    List<int> days = [];
    List<RoutineLogDto> logsByWeek = [];
    for (final week in weeksInLastYear) {
      final startOfWeek = week.start;
      final endOfWeek = week.end;
      final logsForTheWeek = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));
      final routineLogsByDay = groupBy(logsForTheWeek, (log) => log.createdAt.withoutTime().day);
      days.add(routineLogsByDay.length);
      months.add(startOfWeek.abbreviatedMonth());
      logsByWeek.addAll(logsForTheWeek);
    }

    // 3. Now we can safely do sublist & reduce because we have at least 2 entries
    final previousDays = days.sublist(0, days.length - 1);
    final averageOfPrevious = (previousDays.reduce((a, b) => a + b) / previousDays.length).round();

    final sleepLevels = logsByWeek.map((log) => log.sleepLevel).where((score) => score >= 1);

    final averageSleep = sleepLevels.isNotEmpty ? sleepLevels.average : 0;

    final readinessScores = logsByWeek.map((log) {
      final sorenessLevel = log.sorenessLevel;
      final fatigueLevel = log.fatigueLevel;
      return calculateReadinessScore(fatigue: fatigueLevel, soreness: sorenessLevel);
    }).where((score) => score >= 1);

    final averageReadiness = readinessScores.isNotEmpty ? readinessScores.average : -1;

    final trainingFrequency = _generateTrainingFrequencySummary(avgFrequency: averageOfPrevious);

    final sleepPattern = _generateSleepSummary(averageSleepScore: averageSleep.toInt());

    final readinessPattern = getTrainingGuidance(readinessScore: averageReadiness.toInt());

    final trainingSplits = logsByWeek.map((log) {
      final muscleGroups = log.exerciseLogs.map((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup).toSet();
      final trainingSplit = determineTrainingSplit(muscleGroups: muscleGroups);
      return trainingSplit;
    }).toList();

    // Count occurrences
    final Map<TrainingSplit, int> frequencyMap = {};
    for (final split in trainingSplits) {
      frequencyMap[split] = (frequencyMap[split] ?? 0) + 1;
    }

    // Find the most frequent split
    TrainingSplit mostFrequent = TrainingSplit.unknown;
    int maxCount = 0;
    frequencyMap.forEach((split, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = split;
      }
    });

    final trainingSplitSummary = trainingSplits.isNotEmpty ? getTrainingSplitSummary(split: mostFrequent) : "We use your workout split to customize exercise recommendations and ensure every muscle group gets the attention it needs.";

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: context.pop,
          ),
          actions: [
            IconButton(
                onPressed: () => navigateToUserEditor(context: context, user: user),
                icon: const FaIcon(FontAwesomeIcons.solidPenToSquare, size: 24)),
          ]),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 20),
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(spacing: 36, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Center(
                        child: UserIconWidget(size: 60, iconSize: 22),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(user.name.toUpperCase(),
                            style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ]),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 10,
                    children: [
                      _StatisticWidget(
                        title: "$age",
                        subtitle: "Age",
                      ),
                      _StatisticWidget(
                        title: "$weight ${weightUnit()}",
                        subtitle: "Weight",
                      ),
                      _StatisticWidget(
                        title: heightConversion,
                        subtitle: "Height",
                      ),
                      _StatisticWidget(
                        title: gender.name,
                        subtitle: "Gender",
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: _Tile(
                            title: "Training History",
                            subTitle: trainingHistory,
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: _Tile(
                            title: "Training Frequency",
                            subTitle: trainingFrequency,
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 2,
                        child: _Tile(
                          title: "Sleep Pattern",
                          subTitle: sleepPattern,
                          color: averageSleep.toInt() <= 0 ? isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200 : lowToHighIntensityColor(averageSleep / 5),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: _Tile(
                          title: "Recovery",
                          subTitle: readinessPattern,
                          color: averageReadiness.toInt() <= 0 ?  isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200: lowToHighIntensityColor(averageReadiness / 100),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: _Tile(
                            title: "Training Split",
                            subTitle: trainingSplitSummary,
                            color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateAge({required DateTime birthDate}) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    // Adjust if birthday hasn't occurred yet this year
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  String _generateSleepSummary({required int averageSleepScore}) {
    // Fallback in case someone provides a value out of range
    if (averageSleepScore < 1 || averageSleepScore > 5) {
      return "Tracking how much you sleep allows us to gauge recovery and adjust workouts so you stay energized and avoid burnout.";
    }

    // Build a longer explanation based on the score
    String detailedExplanation;
    switch (averageSleepScore) {
      case 1:
        detailedExplanation = "Your sleep patterns indicate you’re getting significantly less rest than recommended "
            "(usually under 5 hours a night). Chronic sleep deprivation can impact mood, recovery, "
            "and overall well-being. Consider scheduling a consistent bedtime and seeking ways to "
            "minimize disturbances.";
        break;
      case 2:
        detailedExplanation =
            "You’re clocking around 5–6 hours of sleep, which is below the optimal range for most adults. "
            "This may affect your energy levels and recovery. Try to establish a nighttime routine and "
            "limit screen time before bed to improve both duration and quality.";
        break;
      case 3:
        detailedExplanation = "At about 6–7 hours of rest, you’re just under the recommended guidelines of 7–8 hours. "
            "While it might be enough for some, you may benefit from an extra 30–60 minutes. "
            "Implementing a consistent schedule and relaxing pre-bedtime activities can help.";
        break;
      case 4:
        detailedExplanation =
            "You’re within the healthy sleep range of 7–8 hours. That’s great! Keep an eye on any factors "
            "that might disrupt sleep—like late-night caffeine or inconsistent bedtimes—to maintain or "
            "further optimize your rest.";
        break;
      case 5:
        detailedExplanation = "You regularly get 8+ hours of quality rest, which is excellent for recovery, "
            "overall health, and day-to-day energy. Continue to prioritize sleep hygiene and "
            "maintain consistent patterns.";
        break;
      default:
        detailedExplanation = "";
        break;
    }
    return detailedExplanation;
  }

  String _generateTrainingFrequencySummary({required int avgFrequency}) {
    if (avgFrequency < 0) {
      return "Knowing how often you train helps us tailor workout plans and rest days to fit your schedule and maximize your results.";
    } else if (avgFrequency == 0) {
      return "Keep logging your training sessions consistently to see insights";
    } else if (avgFrequency < 1) {
      return "You train occasionally, averaging less than one workout per week.";
    } else if (avgFrequency < 2) {
      return "You train about once a week. A consistent schedule could help you progress faster.";
    } else if (avgFrequency < 3) {
      return "You train around twice a week, which is a decent frequency for steady improvement.";
    } else if (avgFrequency < 5) {
      return "You train three to four times a week. This is a well-balanced approach for most goals.";
    } else if (avgFrequency < 7) {
      return "You train five to six times a week, reflecting a high commitment to your fitness routine.";
    } else {
      return "You train seven or more times a week. Be mindful of rest and recovery!";
    }
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;

  const _Tile({required this.title, required this.subTitle, required this.color});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? color.withValues(alpha: 0.1) : color, borderRadius: BorderRadius.circular(5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 4, children: [
        Text(title, style: GoogleFonts.ubuntu(fontSize: 18, height: 1.5, fontWeight: FontWeight.w700)),
        Text(subTitle, style: GoogleFonts.ubuntu(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400)),
      ]),
    );
  }
}

class _StatisticWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatisticWidget({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5), // Border radius for rounded corners
      ),
      child: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(
              height: 6,
            ),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.personWalking,
            size: 50,
          ),
          const SizedBox(height: 50),
          Text(
            "Fitness Profiles",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Text(
            "Your profile helps us personalize your plan, predict progress, and guide recovery—so you get better results, faster.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 50),
          SizedBox(
              height: 45,
              width: double.infinity,
              child: OpacityButtonWidget(
                label: "Create Profile",
                buttonColor: vibrantGreen,
                onPressed: () => navigateToUserEditor(context: context),
              )),
        ],
      ),
    );
  }
}
