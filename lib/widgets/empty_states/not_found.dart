import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/utils/general_utils.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
            child: Center(
          child: RichText(
              text: TextSpan(style: Theme.of(context).textTheme.headlineMedium, children: [
            TextSpan(text: "Not F", style: Theme.of(context).textTheme.headlineMedium),
            const WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 28),
                ),
                alignment: PlaceholderAlignment.middle),
            TextSpan(text: "und", style: Theme.of(context).textTheme.headlineMedium),
          ])),
        )),
      ),
    );
  }
}
