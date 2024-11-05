import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/challengeTemplates/milestone_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';

import '../../../colors.dart';
import '../../enums/milestone_type_enums.dart';
import '../../utils/challenge_utils.dart';

class MilestoneScreen extends StatelessWidget {
  final Milestone milestone;

  const MilestoneScreen({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final progress = 0.3;

    return Scaffold(
      backgroundColor: sapphireDark,
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
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                        onPressed: context.pop,
                      )
                    ]),
                  ),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                      child: Text(milestone.description,
                          style: GoogleFonts.ubuntu(
                              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400, height: 1.8))),
                  const SizedBox(height: 20),
                  const LabelDivider(label: "Details", labelColor: Colors.white70, dividerColor: sapphireLighter),
                  const SizedBox(height: 16),
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.threeLine,
                    leading: const FaIcon(
                      FontAwesomeIcons.book,
                      color: Colors.white70,
                    ),
                    title: Text(milestone.rule,
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.threeLine,
                    leading: const FaIcon(
                      FontAwesomeIcons.trophy,
                      color: Colors.white70,
                    ),
                    title: Text(challengeTargetSummary(type: milestone.type, target: 12),
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  if (milestone.type == MilestoneType.reps)
                    ListTile(
                      titleAlignment: ListTileTitleAlignment.center,
                      leading: Image.asset(
                        'muscles_illustration/chest.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        height: 32,
                      ),
                      title: Text(MuscleGroup.chest.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          textAlign: TextAlign.start),
                    ),
                  if (milestone.type == MilestoneType.hours)
                    ListTile(
                      titleAlignment: ListTileTitleAlignment.center,
                      leading: Image.asset(
                        'muscles_illustration/${MuscleGroup.biceps.illustration()}.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        height: 32,
                      ),
                      title: Text(MuscleGroup.biceps.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
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
                      value: progress,
                      backgroundColor: sapphireDark,
                      color: setsMilestoneColor(progress: 0.3),
                      minHeight: 25,
                      borderRadius: BorderRadius.circular(3.0), // Border r
                    ),
                  ),
                  const SizedBox(height: 10),
                  progress > 0
                      ? RichText(
                          text: TextSpan(
                              text: "Great job! You have conquered",
                              style: GoogleFonts.ubuntu(
                                  height: 1.5, color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                              children: [
                              const TextSpan(text: " "),
                              TextSpan(
                                  text: "${4}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              const TextSpan(text: " "),
                              const TextSpan(text: "out of"),
                              const TextSpan(text: " "),
                              TextSpan(
                                  text: "${12} ${_targetDescription(type: milestone.type)}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              const TextSpan(text: " "),
                              const TextSpan(text: "in this challenge. Keep training to reach the finish line!"),
                            ]))
                      : Text("Keep up the training to see your progress grow for this challenge.",
                          style: GoogleFonts.ubuntu(
                              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400, height: 1.5)),
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OpacityButtonWidget(
                        onLongPress: null,
                        label: "Milestone launching soon",
                        buttonColor: Colors.red,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _targetDescription({required MilestoneType type}) {
    return switch (type) {
      MilestoneType.weekly => "weeks",
      MilestoneType.reps => "reps",
      MilestoneType.days => "days",
      MilestoneType.hours => "hours",
    };
  }
}
