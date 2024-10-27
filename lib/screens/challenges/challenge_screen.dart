import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/challenge_template_extension.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';

import '../../../colors.dart';
import '../../controllers/challenge_log_controller.dart';
import '../../dtos/streaks/challenge_template.dart';
import '../../dtos/streaks/days/days_challenge_dto.dart';
import '../../dtos/streaks/reps/reps_challenge_dto.dart';
import '../../dtos/streaks/weekly/weekly_challenge_dto.dart';
import '../../dtos/streaks/weight/weight_challenge_dto.dart';
import '../../utils/string_utils.dart';

class ChallengeScreen extends StatelessWidget {
  final ChallengeTemplate challengeTemplate;

  const ChallengeScreen({super.key, required this.challengeTemplate});

  @override
  Widget build(BuildContext context) {
    final challengeLogController = Provider.of<ChallengeLogController>(context, listen: true);

    final foundTemplate = challengeLogController.logWhereChallengeTemplateId(id: challengeTemplate.id);

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
                      Text(challengeTemplate.name.toUpperCase(),
                          style:
                              GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                      child: Text(challengeTemplate.description,
                          style: GoogleFonts.montserrat(
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
                    title: Text(challengeTemplate.rule,
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.threeLine,
                    leading: const FaIcon(
                      FontAwesomeIcons.trophy,
                      color: Colors.white70,
                    ),
                    title: Text(_targetSummary(dto: challengeTemplate),
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: sapphireDark.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: sapphireDark,
                      color: vibrantGreen,
                      minHeight: 25,
                      borderRadius: BorderRadius.circular(3.0), // Border r
                    ),
                  ),
                  const Spacer(),
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OpacityButtonWidget(
                        onLongPress: () => foundTemplate != null ? null : _saveChallengeLog(context: context),
                        label: "Tap and hold to commit",
                        buttonColor: vibrantGreen,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _saveChallengeLog({required BuildContext context}) async {
    final challengeLog = challengeTemplate.copyAsChallengeLog();
    await Provider.of<ChallengeLogController>(context, listen: false).saveLog(logDto: challengeLog);
    if (context.mounted) {
      context.pop();
    }
  }

  String _targetSummary({required ChallengeTemplate dto}) {
    if (dto is WeeklyChallengeDto) {
      return "${dto.target} ${pluralize(word: "Week", count: dto.target)}";
    }

    if (dto is RepsChallengeDto) {
      return "${dto.target} ${pluralize(word: "Repetition", count: dto.target)}";
    }

    if (dto is WeightChallengeDto) {
      return "${dto.target} ${pluralize(word: "Tonne", count: dto.target)}";
    }

    if (dto is DaysChallengeDto) {
      return "${dto.target} ${pluralize(word: "Day", count: dto.target)}";
    }
    return "";
  }
}
