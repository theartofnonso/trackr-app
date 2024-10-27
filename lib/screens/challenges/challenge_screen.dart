import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';

import '../../../colors.dart';
import '../../dtos/streaks/challenge_dto.dart';
import '../../dtos/streaks/days/days_challenge_dto.dart';
import '../../dtos/streaks/reps/reps_challenge_dto.dart';
import '../../dtos/streaks/weekly/weekly_challenge_dto.dart';
import '../../dtos/streaks/weight/weight_challenge_dto.dart';
import '../../utils/string_utils.dart';

class ChallengeScreen extends StatelessWidget {
  final Challenge challengeDto;

  const ChallengeScreen({super.key, required this.challengeDto});

  @override
  Widget build(BuildContext context) {
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
                      Text(challengeDto.name.toUpperCase(),
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
                      child: Text(challengeDto.description,
                          style: GoogleFonts.montserrat(
                              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400, height: 1.8))),
                  const SizedBox(height: 20),
                  const LabelDivider(label: "Details", labelColor: Colors.white70, dividerColor: sapphireLighter),
                  const SizedBox(height: 16),
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.threeLine,
                    leading: const FaIcon(FontAwesomeIcons.book, color: Colors.white70,),
                    title: Text(challengeDto.rule,
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  ListTile(
                    titleAlignment: ListTileTitleAlignment.threeLine,
                    leading: const FaIcon(FontAwesomeIcons.trophy, color: Colors.white70,),
                    title: Text(
                        _targetSummary(dto: challengeDto),
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                  ),
                  const Spacer(),
                  SafeArea(
                    child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: GestureDetector(
                          onLongPress: () {
                            print("comitted");
                          },
                          child: OpacityButtonWidget(
                            onPressed: () {},
                            label: "Tap and hold to commit",
                            buttonColor: vibrantGreen,
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _targetSummary({required Challenge dto}) {
    if(dto is WeeklyChallengeDto) {
      return "${dto.target} ${pluralize(word: "Week", count: dto.target)}";
    }

    if(dto is RepsChallengeDto) {
      return "${dto.target} ${pluralize(word: "Repetitions", count: dto.target)}";
    }

    if(dto is WeightChallengeDto) {
      return "${dto.target} ${pluralize(word: "Tonne", count: dto.target)}";
    }

    if(dto is DaysChallengeDto) {
      return "${dto.target} ${pluralize(word: "Day", count: dto.target)}";
    }
    return "";
  }
}
