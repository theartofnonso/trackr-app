import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../shared_prefs.dart';
import '../../widgets/icons/apple_health_icon.dart';
import '../home_screen.dart';
import 'onboarding_step_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  /// Move to the next page if not at the end; otherwise finish onboarding.
  void _onNextPressed({required int steps}) {
    if (_currentIndex < steps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final List<OnboardingStepData> steps = [
      OnboardingStepData(
          title: 'Stay Alert',
          description: 'Stay on track with real-time updates, workout reminders, and progress alerts.',
          image: FaIcon(
            FontAwesomeIcons.solidBell,
            size: 50,
          ),
          positiveAction: () async {
            await requestNotificationPermission();
            _onNextPressed(steps: 2);
          },
          negativeAction: () {
            _onNextPressed(steps: 2);
          },
          positiveActionLabel: 'Turn on notifications',
          negativeActionLabel: 'Skip notifications'),
      OnboardingStepData(
          title: 'Apple Health',
          description: 'Seamlessly sync your health data and unlock personalized insights for optimal training.',
          image: AppleHealthIcon(isDarkMode: isDarkMode, height: 50),
          positiveAction: () async {
            await requestAppleHealth();

            SharedPrefs().firstLaunch = false;

            if (context.mounted) {
              context.replace(HomeScreen.routeName);
            }
          },
          negativeAction: () {
            SharedPrefs().firstLaunch = false;
            context.replace(HomeScreen.routeName);
          },
          positiveActionLabel: "Connect to Apple Health",
          negativeActionLabel: 'Skip connecting to Apple Health'),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: themeGradient(context: context)),
        child: SafeArea(
          minimum: EdgeInsets.all(10),
          child: PageView.builder(
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            itemCount: steps.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final stepData = steps[index];
              return OnboardingStepScreen(
                title: stepData.title,
                description: stepData.description,
                image: stepData.image,
                positiveAction: stepData.positiveAction,
                negativeAction: stepData.negativeAction,
                positiveActionLabel: stepData.positiveActionLabel,
                negativeActionLabel: stepData.negativeActionLabel,
              );
            },
          ),
        ),
      ),
    );
  }
}
