import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../colors.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkBackground : Colors.white,
        ),
        child: SafeArea(
            child: Center(
          child: RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium,
                  children: [
                TextSpan(
                    text: "Not F",
                    style: Theme.of(context).textTheme.headlineMedium),
                const WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 28),
                    ),
                    alignment: PlaceholderAlignment.middle),
                TextSpan(
                    text: "und",
                    style: Theme.of(context).textTheme.headlineMedium),
              ])),
        )),
      ),
    );
  }
}
