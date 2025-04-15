import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/monitors/log_streak_monitor.dart';

import '../../colors.dart';
import '../../utils/theme/theme.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/custom_drawings/streak_face.dart';
import '../../widgets/dividers/label_divider.dart';

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
      _CalenderOnboardingScreen(isDarkMode: isDarkMode),
      _LogStreakMonitorOnboardingScreen(isDarkMode: isDarkMode),
      _TRKRCoachOnboardingScreen(isDarkMode: isDarkMode),
      if (SharedPrefs().firstLaunch) _EndOnboardingScreen(onPress: widget.onComplete ?? () {})
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

class _CalenderOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const _CalenderOnboardingScreen({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          LabelDivider(
            label: "Log Calendar".toUpperCase(),
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
      ),
    );
  }
}

class _LogStreakMonitorOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const _LogStreakMonitorOnboardingScreen({required this.isDarkMode});

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
                  LogStreakWidget(value: 2, width: 120, height: 120, strokeWidth: 8),
                  ClipOval(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: StreakFace(color: logStreakColor(2), result: 0.2),
                      ),
                    ),
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  LogStreakWidget(value: 4, width: 120, height: 120, strokeWidth: 8),
                  ClipOval(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: StreakFace(color: logStreakColor(4), result: 0.4),
                      ),
                    ),
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  LogStreakWidget(value: 7, width: 120, height: 120, strokeWidth: 8),
                  ClipOval(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: StreakFace(color: logStreakColor(7), result: 0.7),
                      ),
                    ),
                  )
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  LogStreakWidget(value: 12, width: 120, height: 120, strokeWidth: 8),
                  ClipOval(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: StreakFace(color: logStreakColor(12), result: 1),
                      ),
                    ),
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

class _TRKRCoachOnboardingScreen extends StatelessWidget {
  final bool isDarkMode;

  const _TRKRCoachOnboardingScreen({required this.isDarkMode});

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

class _EndOnboardingScreen extends StatelessWidget {
  final VoidCallback onPress;

  const _EndOnboardingScreen({required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FaIcon(
          FontAwesomeIcons.personWalking,
          size: 50,
        ),
        const SizedBox(height: 50),
        Text(
          "Start Training Better",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        Text(
          "Ready to get started? Here's to smarter training, meaning insights, and your strongest self.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: SizedBox(
              height: 45,
              width: double.infinity,
              child: OpacityButtonWidget(
                  label: "Start training better",
                buttonColor: vibrantGreen,
                onPressed: onPress,
              )),
        ),
      ],
    );
  }
}
