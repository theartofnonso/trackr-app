import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/open_ai_controller.dart';

import '../../../../dtos/exercise_log_dto.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../../enums/routine_preview_type_enum.dart';
import '../../../utils/routine_utils.dart';
import '../../../widgets/backgrounds/overlay_background.dart';
import '../../../widgets/routine/preview/exercise_log_listview.dart';

class RoutineTemplateAIContextScreen extends StatefulWidget {
  static const routeName = '/routine_template_ai_context_screen';

  final RoutineTemplateDto template;

  const RoutineTemplateAIContextScreen({super.key, required this.template});

  @override
  State<RoutineTemplateAIContextScreen> createState() => _RoutineTemplateAIContextScreenState();
}

class _RoutineTemplateAIContextScreenState extends State<RoutineTemplateAIContextScreen> {
  late RoutineTemplateDto _template;

  bool _loading = false;

  late TextEditingController _textEditingController;

  Timer? _timer;

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: SweepGradient(
          colors: [Colors.green.shade900, Colors.blue.shade900],
          stops: const [0, 1],
          center: Alignment.topRight,
        ),
      ),
      child: Stack(children: [
        SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
                    onPressed: context.pop,
                  ),
                  Expanded(
                    child: Text("TRKR COACH",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                  IconButton(
                    icon: const SizedBox.shrink(),
                    onPressed: context.pop,
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ExerciseLogListView(
                    exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: widget.template.exerciseTemplates),
                    previewType: RoutinePreviewType.ai,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        maxLines: null,
                        decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70), // Customize the color
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // Customize the color for the focused state
                            ),
                            contentPadding: EdgeInsets.zero,
                            hintText: "Ask TRKR Coach anything",
                            hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14)),
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.paperPlane,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: _addMessage,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        if (_loading) const OverlayBackground()
      ]),
    ));
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    Provider.of<OpenAIController>(context, listen: false).createThread();
    _template = widget.template;
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs.map((exerciseLog) {
      return ExerciseLogViewModel(
          exerciseLog: exerciseLog,
          superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
    }).toList();
  }

  void _addMessage() {
    _toggleLoadingState();

    final exercises = _template.exerciseTemplates.map((template) => template.exercise.id);

    final userInstructions = _textEditingController.text.trim();
    final additionalInstructions = "Strictly consider ${exercises.join(",")} when providing suggestions.";
    final messageInstructions = '$userInstructions. $additionalInstructions';

    Provider.of<OpenAIController>(context, listen: false).addMessage(prompt: messageInstructions).then((_) {
      _runAI();
    });
  }

  void _runAI() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final controller = Provider.of<OpenAIController>(context, listen: false);
      if (controller.isRunComplete) {
        _timer?.cancel();
        _toggleLoadingState();
      } else {
        Provider.of<OpenAIController>(context, listen: false).checkRunStatus();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}
