import 'package:flutter/material.dart';

class OnboardingStepData {
  final String title;
  final String description;
  final Widget image;
  final void Function() positiveAction;

  OnboardingStepData({
    required this.title,
    required this.description,
    required this.image,
    required this.positiveAction,
  });
}


class OnboardingStepScreen extends StatelessWidget {
  final String title;
  final String description;
  final Widget image;

  const OnboardingStepScreen({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         image,
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Home Screen - Onboarding Completed!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}