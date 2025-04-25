import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../utils/theme/theme.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

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
    final pages = [_EndOnboardingScreen(onPress: widget.onComplete ?? () {})];

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
