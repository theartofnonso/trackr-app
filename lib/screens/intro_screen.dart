import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../colors.dart';
import '../dtos/milestones/reps_milestone.dart';
import '../enums/muscle_group_enums.dart';
import '../widgets/buttons/opacity_button_widget.dart';
import '../widgets/calendar/calendar.dart';
import '../widgets/chart/muscle_group_family_frequency_chart.dart';
import '../widgets/label_divider.dart';
import '../widgets/milestones/milestone_grid_item.dart';
import '../widgets/monitors/log_streak_monitor.dart';
import '../widgets/monitors/muscle_trend_monitor.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = "/intro_screen";

  final ThemeData themeData;
  final VoidCallback? onComplete;

  const IntroScreen({super.key, required this.themeData, this.onComplete});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pageController = PageController(viewportFraction: 1);

  @override
  Widget build(BuildContext context) {
    final pages = [
      CalenderOnboardingScreen(),
      LogStreakMonitorOnboardingScreen(),
      MuscleTrendMonitorOnboardingScreen(),
      TRKRCoachOnboardingScreen(),
      MilestonesOnboardingScreen(),
      if (SharedPrefs().firstLaunch) EndOnboardingScreen(onLongPress: widget.onComplete ?? () {})
    ];

    return MaterialApp(
      theme: widget.themeData,
      home: Scaffold(
          appBar: AppBar(
              backgroundColor: sapphireDark80,
              leading: !SharedPrefs().firstLaunch
                  ? IconButton(
                      icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
                      onPressed: () => context.pop(),
                    )
                  : null,
              title: Text("Welcome to TRKR",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))),
          body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sapphireDark80,
                    sapphireDark,
                  ],
                ),
              ),
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
                  SafeArea(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: pages.length,
                      effect: const ExpandingDotsEffect(activeDotColor: vibrantGreen),
                    ),
                  ),
                ],
              ))),
    );
  }
}

class CalenderOnboardingScreen extends StatelessWidget {
  const CalenderOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          LabelDivider(
            label: "LOG Calender".toUpperCase(),
            labelColor: Colors.white,
            dividerColor: sapphireLighter,
            fontSize: 14,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
              "Today marks the beginning of your lifelong commitment to self-improvement. The app might look empty now, but as you log each workout, you’ll start seeing vibrant green squares filling up your calendar—visual proof of your dedication and progress.",
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400, height: 2)),
          SizedBox(
            height: 20,
          ),
          Calendar(dateTime: DateTime.now()),
        ],
      ),
    );
  }
}

class LogStreakMonitorOnboardingScreen extends StatelessWidget {
  const LogStreakMonitorOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(10.0),
      child: Column(
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
                    LogStreakMonitor(
                        value: 0.2,
                        width: 120,
                        height: 120,
                        strokeWidth: 8,
                        decoration: BoxDecoration(
                          color: sapphireDark.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(100),
                        )),
                    Image.asset(
                      'images/trkr.png',
                      fit: BoxFit.contain,
                      color: Colors.white54,
                      height: 8, // Adjust the height as needed
                    )
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    LogStreakMonitor(
                        value: 0.4,
                        width: 120,
                        height: 120,
                        strokeWidth: 8,
                        decoration: BoxDecoration(
                          color: sapphireDark.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(100),
                        )),
                    Image.asset(
                      'images/trkr.png',
                      fit: BoxFit.contain,
                      color: Colors.white54,
                      height: 8, // Adjust the height as needed
                    )
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    LogStreakMonitor(
                        value: 0.6,
                        width: 120,
                        height: 120,
                        strokeWidth: 8,
                        decoration: BoxDecoration(
                          color: sapphireDark.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(100),
                        )),
                    Image.asset(
                      'images/trkr.png',
                      fit: BoxFit.contain,
                      color: Colors.white54,
                      height: 8, // Adjust the height as needed
                    )
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    LogStreakMonitor(
                        value: 0.8,
                        width: 120,
                        height: 120,
                        strokeWidth: 8,
                        decoration: BoxDecoration(
                          color: sapphireDark.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(100),
                        )),
                    Image.asset(
                      'images/trkr.png',
                      fit: BoxFit.contain,
                      color: Colors.white54,
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
            labelColor: Colors.white,
            dividerColor: sapphireLighter,
            fontSize: 14,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
              "Your goal is to keep those months consistently green. Just 12 sessions per month are all you need to close the ring and maintain your momentum. Make it a habit, keep pushing, and enjoy watching your streaks grow!",
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400, height: 2)),
        ],
      ),
    );
  }
}

class MuscleTrendMonitorOnboardingScreen extends StatelessWidget {
  const MuscleTrendMonitorOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muscleMap = <MuscleGroupFamily, double>{
      MuscleGroupFamily.legs: 0.7,
      MuscleGroupFamily.arms: 0.5,
      MuscleGroupFamily.back: 0.3
    };

    return SafeArea(
      minimum: const EdgeInsets.all(10.0),
      child: Column(
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
                    color: Colors.white54,
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
            labelColor: Colors.white,
            dividerColor: sapphireLighter,
            fontSize: 14,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
              "To get the most out of your training, aim for balance across all muscle groups. By keeping an eye on your muscle trends, you can prevent imbalances, reduce the risk of injury, and ensure well-rounded strength development.",
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400, height: 2)),
        ],
      ),
    );
  }
}

class MilestonesOnboardingScreen extends StatelessWidget {
  const MilestonesOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final milestonesChildren =
        RepsMilestone.loadMilestones(logs: []).map((milestone) => MilestoneGridItem(milestone: milestone)).toList();

    return SafeArea(
      minimum: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          LabelDivider(
            label: "Milestones".toUpperCase(),
            labelColor: Colors.white,
            dividerColor: sapphireLighter,
            fontSize: 14,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
              "Finally, to keep you motivated, we’ve added challenges and milestones to mark your achievements. Push yourself, set new goals, and try to unlock as many challenges as possible throughout the year!",
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400, height: 2)),
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
      ),
    );
  }
}

class TRKRCoachOnboardingScreen extends StatelessWidget {
  const TRKRCoachOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(10.0),
      child: Column(
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
            labelColor: Colors.white,
            dividerColor: sapphireLighter,
            fontSize: 14,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
              "We know starting (or revamping) a training routine can feel overwhelming, so we’ve introduced TRKR Coach—your personal AI assistant. Need guidance on form, a new workout idea, or feedback on your progress? Just ask TRKR Coach, and you’ll have instant, expert insight at your fingertips.",
              style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400, height: 2)),
        ],
      ),
    );
  }
}

class EndOnboardingScreen extends StatelessWidget {
  final VoidCallback onLongPress;

  const EndOnboardingScreen({super.key, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(
                  text: "Ready to get started? Here’s to",
                  style:
                      GoogleFonts.ubuntu(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w500, height: 1.5),
                  children: [
                TextSpan(
                    text: " smarter training, ",
                    style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                TextSpan(
                    text: "meaningful insights",
                    style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
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
                onLongPress: () {
                  HapticFeedback.vibrate();
                  onLongPress();
                },
              ))
        ],
      ),
    );
  }
}
