import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/streaks/weight_challenge_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';
import 'package:tracker_app/widgets/pickers/muscle_picker.dart';

import '../../../colors.dart';
import '../../controllers/challenge_log_controller.dart';
import '../../dtos/appsync/challenge_log_dto.dart';
import '../../dtos/streaks/challenge_template.dart';
import '../../dtos/streaks/reps_challenge_dto.dart';
import '../../utils/challenge_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/routine_editors_utils.dart';

class ChallengeScreen extends StatefulWidget {
  final ChallengeTemplate challengeTemplate;

  const ChallengeScreen({super.key, required this.challengeTemplate});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  MuscleGroup _selectedMuscleGroup = MuscleGroup.none;

  ExerciseDto? _selectedExercise;

  double _targetWeight = 0;

  final _confettiController = ConfettiController();

  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final challengeLogController = Provider.of<ChallengeLogController>(context, listen: true);

    final activeChallenge = challengeLogController.logWhereChallengeTemplateId(id: widget.challengeTemplate.id);

    final selectedExercise = _selectedExercise;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
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
                            Text(widget.challengeTemplate.name.toUpperCase(),
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
                          child: Text(widget.challengeTemplate.description,
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
                        title: Text(widget.challengeTemplate.rule,
                            style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                      ),
                      if (widget.challengeTemplate is! WeightChallengeDto)
                        ListTile(
                          titleAlignment: ListTileTitleAlignment.threeLine,
                          leading: const FaIcon(
                            FontAwesomeIcons.trophy,
                            color: Colors.white70,
                          ),
                          title: Text(challengeTargetSummary(dto: widget.challengeTemplate),
                              style:
                                  GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400)),
                        ),
                      if (widget.challengeTemplate is RepsChallengeDto)
                        ListTile(
                          onTap: _selectMuscleGroup,
                          titleAlignment: ListTileTitleAlignment.center,
                          leading: _selectedMuscleGroup == MuscleGroup.none
                              ? const FaIcon(
                                  FontAwesomeIcons.solidCircleQuestion,
                                  color: Colors.white70,
                                )
                              : Image.asset(
                                  'muscles_illustration/${_selectedMuscleGroup.illustration()}.png',
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.low,
                                  height: 32,
                                ),
                          title: Text(
                              _selectedMuscleGroup == MuscleGroup.none
                                  ? "Select Muscle Group"
                                  : _selectedMuscleGroup.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              textAlign: TextAlign.start),
                          trailing: const FaIcon(
                            FontAwesomeIcons.circleArrowRight,
                            color: Colors.white70,
                          ),
                        ),
                      if (widget.challengeTemplate is WeightChallengeDto)
                        ListTile(
                          onTap: _selectExercise,
                          titleAlignment: ListTileTitleAlignment.center,
                          leading: const FaIcon(
                            FontAwesomeIcons.trophy,
                            color: Colors.white70,
                          ),
                          title: _TextField(
                            value: _targetWeight,
                            onChanged: (value) {
                              setState(() {
                                _targetWeight = value;
                              });
                            },
                            controller: _textEditingController,
                          ),
                        ),
                      if (widget.challengeTemplate is WeightChallengeDto)
                        ListTile(
                          onTap: _selectExercise,
                          titleAlignment: ListTileTitleAlignment.center,
                          leading: selectedExercise != null
                              ? Image.asset(
                                  'muscles_illustration/${selectedExercise.primaryMuscleGroup.illustration()}.png',
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.low,
                                  height: 32,
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.solidCircleQuestion,
                                  color: Colors.white70,
                                ),
                          title: Text(selectedExercise != null ? selectedExercise.name : "Select Exercise",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              textAlign: TextAlign.start),
                          trailing: const FaIcon(
                            FontAwesomeIcons.circleArrowRight,
                            color: Colors.white70,
                          ),
                        ),
                      if (activeChallenge != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const LabelDivider(
                                label: "Progress", labelColor: Colors.white70, dividerColor: sapphireLighter),
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
                          ],
                        ),
                      SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OpacityButtonWidget(
                            onLongPress: () => activeChallenge != null
                                ? _deleteChallengeLog(challenge: activeChallenge)
                                : _saveChallengeLog(),
                            label: activeChallenge != null ? "Quit Challenge" : "Tap and hold to commit",
                            buttonColor: activeChallenge != null ? Colors.red : vibrantGreen,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
        ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive)
      ],
    );
  }

  void _selectMuscleGroup() {
    displayBottomSheet(
        height: 240,
        context: context,
        child: MusclePicker(
          onSelect: (MuscleGroup muscleGroup) {
            Navigator.of(context).pop();
            setState(() {
              _selectedMuscleGroup = muscleGroup;
            });
          },
          initialMuscleGroup: _selectedMuscleGroup,
        ));
  }

  void _selectExercise() {
    showExercisesInLibrary(
        context: context,
        exclude: [],
        onSelected: (List<ExerciseDto> selectedExercises) {
          if (selectedExercises.isNotEmpty) {
            setState(() {
              _selectedExercise = selectedExercises.first;
            });
          }
        });
  }

  void _saveChallengeLog() async {
    if (widget.challengeTemplate is RepsChallengeDto) {
      if (_selectedMuscleGroup == MuscleGroup.none) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: "Please select a muscle group for this challenge");
        return;
      }
    }

    if (widget.challengeTemplate is WeightChallengeDto) {
      if (_targetWeight <= 0) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: "Please enter a target weight for this challenge");
        return;
      }

      final selectedExercise = _selectedExercise;
      if (selectedExercise == null) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: "Please select an exercise for this challenge");
        return;
      }
    }
    //
    // final challengeLog = widget.challengeTemplate.createChallenge(startDate: DateTime.now());
    // await Provider.of<ChallengeLogController>(context, listen: false).saveLog(logDto: challengeLog);

    _confettiController.play();

    HapticFeedback.vibrate();
  }

  void _deleteChallengeLog({required ChallengeLogDto challenge}) async {
    HapticFeedback.vibrate();
    await Provider.of<ChallengeLogController>(context, listen: false).removeLog(log: challenge);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

class _TextField extends StatelessWidget {
  final num value;
  final TextEditingController controller;
  final void Function(double value) onChanged;

  const _TextField({required this.controller, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) => onChanged(_parseDoubleOrDefault(value: value)),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Colors.white70)),
          fillColor: Colors.transparent,
          hintText: "${value > 0 ? weightWithConversion(value: value) : '0'}",
          hintStyle: GoogleFonts.ubuntu(color: Colors.white70)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLines: 1,
      textAlign: TextAlign.start,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
    );
  }

  double _parseDoubleOrDefault({required String value}) {
    return double.tryParse(value) ?? 0;
  }
}
