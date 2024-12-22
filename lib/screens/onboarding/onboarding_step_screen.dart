import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../widgets/buttons/solid_button_widget.dart';

class OnboardingStepData {
  final String title;
  final String description;
  final Widget image;
  final void Function() positiveAction;
  final void Function() negativeAction;
  final String positiveActionLabel;
  final String negativeActionLabel;

  OnboardingStepData(
      {required this.title,
      required this.description,
      required this.image,
      required this.positiveAction,
        required this.negativeAction,
      required this.positiveActionLabel, required this.negativeActionLabel});
}

class OnboardingStepScreen extends StatelessWidget {
  final String title;
  final String description;
  final Widget image;
  final void Function() positiveAction;
  final void Function() negativeAction;
  final String positiveActionLabel;
  final String negativeActionLabel;

  const OnboardingStepScreen({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.positiveAction,
    required this.negativeAction,
    required this.positiveActionLabel, required this.negativeActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          image,
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 40),
          SizedBox(
              height: 45,
              width: double.infinity,
              child: OpacityButtonWidget(
                label: positiveActionLabel,
                buttonColor: vibrantGreen,
                onPressed: positiveAction,
              )),
          const Spacer(),
          SizedBox(
              height: 45,
              width: double.infinity,
              child: SolidButtonWidget(
                label: negativeActionLabel,
                buttonColor: Colors.transparent,
                onPressed: negativeAction,
              ))
        ],
      ),
    );
  }
}
