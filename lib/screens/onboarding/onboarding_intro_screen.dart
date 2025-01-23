import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../dtos/milestones/reps_milestone.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/theme/theme.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/chart/muscle_group_family_frequency_chart.dart';
import '../../widgets/dividers/label_divider.dart';
import '../../widgets/milestones/milestone_grid_item.dart';
import '../../widgets/monitors/log_streak_monitor.dart';
import '../../widgets/monitors/muscle_trend_monitor.dart';

class OnboardingIntroScreen extends StatefulWidget {
  static const routeName = "/intro_screen";

  final VoidCallback? onComplete;

  const OnboardingIntroScreen({super.key, this.onComplete});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  final _pageController = PageController(viewportFraction: 1);

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final pages = [
      CalenderOnboardingScreen(isDarkMode: isDarkMode),
      LogStreakMonitorOnboardingScreen(isDarkMode: isDarkMode),
      MuscleTrendMonitorOnboardingScreen(isDarkMode: isDarkMode),
      TRKRCoachOnboardingScreen(isDarkMode: isDarkMode),
      MilestonesOnboardingScreen(isDarkMode: isDarkMode),
      if (SharedPrefs().firstLaunch) EndOnboardingScreen(onLongPress: widget.onComplete ?? () {})
    ];

    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: TRKRTheme.lightTheme,
      darkTheme: TRKRTheme.darkTheme,
      home: Scaffold(
          appBar: AppBar(
              leading: !SharedPrefs().firstLaunch
                  ? IconButton(
                      icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
                      onPressed: () => context.pop(),
                    )
                  : null,
              title: Text("Welcome to TRKR".toUpperCase())),
          body: Container(
              decoration: BoxDecoration(
                gradient: themeGradient(context: context),
              ),
              child: SafeArea(
                minimum: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        itemCount: pages.length,
                        itemBuilder: (_, index) {
                          return pages[index % pages.length];
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: pages.length,
                      effect: const ExpandingDotsEffect(activeDotColor: vibrantGreen),
                    )
                  ],
                ),
              ))),
    );
  }
}

class CalenderOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const CalenderOnboardingScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabelDivider(
          label: "LOG Calender".toUpperCase(),
          labelColor: isDarkMode ? Colors.white70 : Colors.black,
          dividerColor: sapphireLighter,
          fontSize: 14,
        ),
        SizedBox(
          height: 12,
        ),
        Text(
            "Today marks the beginning of your lifelong commitment to self-improvement. The app might look empty now, but as you log each workout, you’ll start seeing vibrant green squares filling up your calendar—visual proof of your dedication and progress.",
            style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(
          height: 20,
        ),
        Calendar(dateTime: DateTime.now()),
      ],
    );
  }
}

class LogStreakMonitorOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const LogStreakMonitorOnboardingScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Wrap(
            runSpacing: 40,
            spacing: 40,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  LogStreakMonitor(value: 2, width: 120, height: 120, strokeWidth: 8),
                  Image.asset(
                    'images/trkr.png',
                    fit: BoxFit.contain,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    height: 8, // Adjust the height as needed
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  LogStreakMonitor(value: 4, width: 120, height: 120, strokeWidth: 8),
                  Image.asset(
                    'images/trkr.png',
                    fit: BoxFit.contain,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    height: 8, // Adjust the height as needed
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  LogStreakMonitor(value: 7, width: 120, height: 120, strokeWidth: 8),
                  Image.asset(
                    'images/trkr.png',
                    fit: BoxFit.contain,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    height: 8, // Adjust the height as needed
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  LogStreakMonitor(value: 12, width: 120, height: 120, strokeWidth: 8),
                  Image.asset(
                    'images/trkr.png',
                    fit: BoxFit.contain,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    height: 8, // Adjust the height as needed
                  )
                ],
              )
            ],
          ),
        ),
        const Spacer(),
        LabelDivider(
          label: "LOG Streak".toUpperCase(),
          labelColor: isDarkMode ? Colors.white70 : Colors.black,
          dividerColor: sapphireLighter,
          fontSize: 14,
        ),
        SizedBox(
          height: 12,
        ),
        Text(
            "Your goal is to keep those months consistently green. Just 12 sessions per month are all you need to close the ring and maintain your momentum. Make it a habit, keep pushing, and enjoy watching your streaks grow!",
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class MuscleTrendMonitorOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const MuscleTrendMonitorOnboardingScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final muscleMap = <MuscleGroupFamily, double>{
      MuscleGroupFamily.legs: 0.7,
      MuscleGroupFamily.arms: 0.5,
      MuscleGroupFamily.back: 0.3
    };

    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                MuscleTrendMonitor(value: 60 / 100, width: 120, height: 120, strokeWidth: 8),
                Image.asset(
                  'images/trkr.png',
                  fit: BoxFit.contain,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                  height: 8, // Adjust the height as needed
                )
              ],
            ),
          ),
        ),
        const Spacer(),
        MuscleGroupFamilyFrequencyChart(frequencyData: muscleMap, minimized: true),
        const Spacer(),
        LabelDivider(
          label: "Muscle Trend".toUpperCase(),
          labelColor: isDarkMode ? Colors.white70 : Colors.black,
          dividerColor: sapphireLighter,
          fontSize: 14,
        ),
        SizedBox(
          height: 12,
        ),
        Text(
            "To get the most out of your training, aim for balance across all muscle groups. By keeping an eye on your muscle trends, you can prevent imbalances, reduce the risk of injury, and ensure well-rounded strength development.",
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class MilestonesOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const MilestonesOnboardingScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final milestonesChildren =
        RepsMilestone.loadMilestones(logs: []).map((milestone) => MilestoneGridItem(milestone: milestone)).toList();

    return Column(
      children: [
        LabelDivider(
          label: "Milestones".toUpperCase(),
          labelColor: isDarkMode ? Colors.white70 : Colors.black,
          dividerColor: sapphireLighter,
          fontSize: 14,
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
            "Finally, to keep you motivated, we’ve added challenges and milestones to mark your achievements. Push yourself, set new goals, and try to unlock as many challenges as possible throughout the year!",
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(
          height: 14,
        ),
        Expanded(
          child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              children: milestonesChildren),
        ),
      ],
    );
  }
}

class TRKRCoachOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const TRKRCoachOnboardingScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    vibrantBlue,
                    vibrantBlue,
                    vibrantGreen,
                    vibrantGreen // End color
                  ],
                  begin: Alignment.topLeft, // Gradient starts from top-left
                  end: Alignment.bottomRight, // Gradient ends at bottom-right
                ),
                borderRadius: BorderRadius.circular(8)),
            child: Image.asset(
              'images/trkr_single_icon.png',
              fit: BoxFit.contain,
              height: 12, // Adjust the height as needed
            )),
        Spacer(),
        LabelDivider(
          label: "TRKR COACH".toUpperCase(),
          labelColor: isDarkMode ? Colors.white70 : Colors.black,
          dividerColor: sapphireLighter,
          fontSize: 14,
        ),
        SizedBox(
          height: 12,
        ),
        Text(
            "We know starting (or revamping) a training routine can feel overwhelming, so we’ve introduced TRKR Coach—your personal AI assistant. Need guidance on form, a new workout idea, or feedback on your progress? Just ask TRKR Coach, and you’ll have instant, expert insight at your fingertips.",
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class EndOnboardingScreen extends StatelessWidget {
  final VoidCallback onLongPress;

  const EndOnboardingScreen({super.key, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
            text: TextSpan(
                text: "Ready to get started? Here’s to",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontSize: 22, fontWeight: FontWeight.w500, height: 1.5),
                children: [
              TextSpan(
                  text: " smarter training, ",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w600)),
              TextSpan(
                  text: "meaningful insights",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w600)),
              const TextSpan(
                text: ", and your brightest fitness future.",
              ),
            ])),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            child: OpacityButtonWidget(
              padding: const EdgeInsets.symmetric(vertical: 16),
              buttonColor: vibrantGreen,
              label: "Tap and hold to start training",
              onLongPress: onLongPress,
            ))
      ],
    );
  }
}
