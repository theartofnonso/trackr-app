import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:video_player/video_player.dart';

import '../../utils/theme/theme.dart';

// ---------------------------------------------------------------------------
//  FULL‑SCREEN VIDEO + SOFT BLUR + OVERLAYED TEXT & CTA BUTTON
// ---------------------------------------------------------------------------
//  * Plays an asset‑based video that fills the screen (autoplay + loop).
//  * Applies a configurable gaussian blur (`blurSigma`) over the video.
//  * Adds a fade gradient for readability plus headline & button at bottom.
// ---------------------------------------------------------------------------

class OnboardingFlowScreen extends StatefulWidget {
  static const routeName = '/onboarding_flow_screen';

  final void Function()? onPressed;

  const OnboardingFlowScreen({super.key, this.onPressed});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("images/video.MOV")
      ..setLooping(true)
      ..setVolume(0)
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: TRKRTheme.lightTheme,
      darkTheme: TRKRTheme.darkTheme,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ----------------- FULL‑SCREEN VIDEO -----------------
            Positioned.fill(
              child: _controller.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            // ----------------- BLUR LAYER ------------------------
            // Uses BackdropFilter to blur everything beneath it.
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Container(
                    // transparent container is required
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),

            // ----------------- TOP→BOTTOM FADE ------------------
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
            // ----------------- BOTTOM OVERLAY --------------------
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'images/trkr.png',
                      fit: BoxFit.contain,
                      color: Colors.white,
                      height: 20, // Adjust the height as needed
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Casual lifters, serious results. We do the thinking, you do the lifting.",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: OpacityButtonWidget(label: "Start training better", onPressed: widget.onPressed, buttonColor: vibrantGreen))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
