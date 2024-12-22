import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'onboarding_step_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingStepData> _steps = [
    OnboardingStepData(
      title: 'Welcome',
      description: 'Discover how our app can help track your workouts.',
      image: FaIcon(FontAwesomeIcons.circle),
        positiveAction: () {}
    ),
    OnboardingStepData(
      title: 'Track Progress',
      description: 'Log sets, reps, and weights to see your progress over time.',
        image: FaIcon(FontAwesomeIcons.circle),
        positiveAction: () {}
    ),
    OnboardingStepData(
      title: 'Stay Motivated',
      description:
      'Get personalized insights, feedback, and stay on top of your goals.',
        image: FaIcon(FontAwesomeIcons.circle),
        positiveAction: () {}
    ),
  ];

  /// Move to the next page if not at the end; otherwise finish onboarding.
  void _onNextPressed() {
    if (_currentIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onSkipPressed() {
    // Optionally, skip straight to the end or do any other logic
    _finishOnboarding();
  }

  /// Logic to finish onboarding (navigate to main app screen, etc.)
  void _finishOnboarding() {
    // TODO: Replace with your actual navigation to home screen or wherever
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main PageView for onboarding steps
          PageView.builder(
            controller: _pageController,
            itemCount: _steps.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final stepData = _steps[index];
              return OnboardingStepScreen(
                title: stepData.title,
                description: stepData.description,
                image: stepData.image,
              );
            },
          ),

          // Bottom action buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white.withOpacity(0.9),
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (optional)
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: const Text('Skip'),
                  ),

                  // Page indicator or dots (optional)
                  Row(
                    children: List.generate(
                      _steps.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Next / Finish Button
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    child: Text(
                      _currentIndex == _steps.length - 1
                          ? 'Finish'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}