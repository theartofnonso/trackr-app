import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';

import '../../../colors.dart';
import '../../controllers/challenge_log_controller.dart';
import '../../dtos/appsync/challenge_log_dto.dart';
import '../../enums/challenge_type_enums.dart';
import '../../repositories/challenge_templates.dart';
import '../../utils/challenge_utils.dart';

class ActiveChallengeScreen extends StatelessWidget {
  final ChallengeLogDto log;

  const ActiveChallengeScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final challenges = ChallengeTemplates().loadTemplates();

    final template = challenges.firstWhere((template) => template.id == log.templateId);

    final templateTarget = template.target <= 0 ? log.weight : template.target;

    final progress = log.progress / templateTarget;

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
                        Text(log.name.toUpperCase(),
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
                      child: Text(log.description,
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
                    title: Text(log.rule,
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.threeLine,
                    leading: const FaIcon(
                      FontAwesomeIcons.trophy,
                      color: Colors.white70,
                    ),
                    title: Text(
                        challengeTargetSummary(
                            type: log.type, target: log.type == ChallengeType.weight ? log.weight : template.target),
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  if (log.type == ChallengeType.reps)
                    ListTile(
                      titleAlignment: ListTileTitleAlignment.center,
                      leading: Image.asset(
                        'muscles_illustration/${log.muscleGroup.illustration()}.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        height: 32,
                      ),
                      title: Text(log.muscleGroup.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          textAlign: TextAlign.start),
                    ),
                  if (log.type == ChallengeType.weight)
                    ListTile(
                      titleAlignment: ListTileTitleAlignment.center,
                      leading: Image.asset(
                        'muscles_illustration/${log.exercise?.primaryMuscleGroup.illustration()}.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        height: 32,
                      ),
                      title: Text("${log.exercise?.name}",
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
                      color: vibrantGreen,
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
                                  text: "${log.progress}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              const TextSpan(text: " "),
                              const TextSpan(text: "out of"),
                              const TextSpan(text: " "),
                              TextSpan(
                                  text: "${template.target} ${_targetDescription(type: log.type)}",
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
                        onLongPress: () => _deleteChallengeLog(context: context),
                        label: "Tap and hold to quit",
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

  void _deleteChallengeLog({required BuildContext context}) async {
    HapticFeedback.vibrate();
    await Provider.of<ChallengeLogController>(context, listen: false).removeLog(log: log);
    if (context.mounted) {
      context.pop();
    }
  }

  String _targetDescription({required ChallengeType type}) {
    return switch (type) {
      ChallengeType.weekly => "weeks",
      ChallengeType.reps => "reps",
      ChallengeType.days => "days",
      ChallengeType.weight => weightLabel(),
    };
  }
}
