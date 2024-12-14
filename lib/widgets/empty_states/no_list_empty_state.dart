import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoListEmptyState extends StatelessWidget {
  final Widget? icon;
  final String message;

  const NoListEmptyState({super.key, this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon ?? FaIcon(FontAwesomeIcons.solidLightbulb, size: 38),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge)
        ]);
  }
}
