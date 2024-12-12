import 'package:collection/collection.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/dtos/milestones/reps_milestone.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/label_divider.dart';
import 'package:tracker_app/widgets/shareables/milestone_shareable.dart';

import '../../../colors.dart';
import '../../enums/milestone_type_enums.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/shareables_utils.dart';

class MilestoneScreen extends StatelessWidget {
  final Milestone milestone;

  const MilestoneScreen({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final remainder = (milestone.progress.$1 * milestone.target).toInt();

    final confettiController = ConfettiController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      confettiController.play();
    });

    final sortedMilestones = milestone.progress.$2.sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    return Stack(alignment: Alignment.topCenter, children: [
      Scaffold(
        backgroundColor: sapphireDark,
        floatingActionButton: milestone.progress.$1 == 1
            ? FloatingActionButton(
                heroTag: "milestone_screen",
                onPressed: () => _shareMilestoneSummary(context: context),
                backgroundColor: sapphireDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const FaIcon(FontAwesomeIcons.rocket))
            : null,
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(children: [
                  Positioned.fill(
                      child: Image.asset(
                    'images/man_woman.jpg',
                    fit: BoxFit.cover,
                  )),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          sapphireDark.withOpacity(0.4),
                          sapphireDark.withOpacity(0.8),
                          sapphireDark,
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(milestone.name.toUpperCase(),
                              style:
                                  GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
                          onPressed: context.pop,
                        )
                      ]),
                    ),
                  )
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Center(
                              child: Text(milestone.description,
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400, height: 1.8))),
                          const SizedBox(height: 20),
                          const LabelDivider(
                              label: "Details", labelColor: Colors.white70, dividerColor: sapphireLighter),
                          const SizedBox(height: 16),
                          ListTile(
                            titleAlignment: ListTileTitleAlignment.threeLine,
                            leading: const FaIcon(
                              FontAwesomeIcons.book,
                              color: Colors.white70,
                            ),
                            title: Text(milestone.rule,
                                style:
                                    GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                          ),
                          ListTile(
                            titleAlignment: ListTileTitleAlignment.threeLine,
                            leading: const FaIcon(
                              FontAwesomeIcons.trophy,
                              color: Colors.white70,
                            ),
                            title: Text(challengeTargetSummary(type: milestone.type, target: milestone.target),
                                style:
                                    GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                          ),
                          if (milestone.type == MilestoneType.reps)
                            ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              leading: Image.asset(
                                'muscles_illustration/${(milestone as RepsMilestone).muscleGroup.illustration()}.png',
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low,
                                height: 32,
                              ),
                              title: Text((milestone as RepsMilestone).muscleGroup.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                  textAlign: TextAlign.start),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: sapphireDark.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: LinearProgressIndicator(
                              value: milestone.progress.$1,
                              backgroundColor: sapphireDark,
                              color: setsMilestoneColor(progress: milestone.progress.$1),
                              minHeight: 25,
                              borderRadius: BorderRadius.circular(3.0), // Border r
                            ),
                          ),
                          const SizedBox(height: 16),
                          milestone.progress.$1 > 0
                              ? milestone.progress.$1 == 1
                                  ? _CompletedMessage(target: milestone.target, description: _targetDescription())
                                  : _ProgressMessage(
                                      remainder: remainder, target: milestone.target, description: _targetDescription())
                              : Text("Keep up the training to see your progress grow for this challenge.",
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400, height: 1.5)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      milestone.progress.$1 == 1
          ? ConfettiWidget(
              minBlastForce: 10,
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive)
          : const SizedBox.shrink()
    ]);
  }

  String _targetDescription() {
    return switch (milestone.type) {
      MilestoneType.weekly => "weeks",
      MilestoneType.reps => "reps",
      MilestoneType.days => "days",
      MilestoneType.hours => "hours",
    };
  }

  void _shareMilestoneSummary({required BuildContext context}) {
    if (kReleaseMode) {
      Posthog().capture(eventName: PostHogAnalyticsEvent.shareMilesStone.displayName);
    }
    onShare(
        context: context,
        globalKey: milestoneGlobalKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.award, color: vibrantGreen, size: 32),
                const SizedBox(height: 20),
                Text(milestone.name,
                    style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                Text(milestone.caption,
                    style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 50),
                Image.asset(
                  'images/trkr.png',
                  fit: BoxFit.contain,
                  height: 8, // Adjust the height as needed
                ),
              ]),
        ));
  }
}

class _ProgressMessage extends StatelessWidget {
  final int remainder;
  final int target;
  final String description;

  const _ProgressMessage({required this.remainder, required this.target, required this.description});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            text: "Great job! You have conquered",
            style: GoogleFonts.ubuntu(height: 1.5, color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            children: [
          const TextSpan(text: " "),
          TextSpan(
              text: "$remainder",
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const TextSpan(text: " "),
          const TextSpan(text: "out of"),
          const TextSpan(text: " "),
          TextSpan(
              text: "$target $description",
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const TextSpan(text: " "),
          const TextSpan(text: "in this challenge. Keep training to reach the finish line!"),
        ]));
  }
}

class _CompletedMessage extends StatelessWidget {
  final int target;
  final String description;

  const _CompletedMessage({required this.target, required this.description});

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            text: "Great job! You have successfully completed",
            style: GoogleFonts.ubuntu(height: 1.5, color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            children: [
          const TextSpan(text: " "),
          TextSpan(
              text: "$target $description",
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const TextSpan(text: " "),
          const TextSpan(text: "in this challenge. Keep training to complete more milestones!"),
        ]));
  }
}
