import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoListEmptyState extends StatelessWidget {
  final Widget? icon;
  final String message;
  final bool showIcon;

  const NoListEmptyState({super.key, this.icon, required this.message, this.showIcon = true});

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(showIcon)
            icon ?? FaIcon(FontAwesomeIcons.solidLightbulb, size: 30, color: isDarkMode ? Colors.white70 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: isDarkMode ? Colors.white70 : Colors.grey.shade400)),
          )
        ]);
  }
}
