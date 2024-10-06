import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../dtos/exercise_log_dto.dart';
import '../../../colors.dart';
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
  RoutineTemplateDto? _template;

  bool _loading = false;

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
          colors: [vibrantBlue.withOpacity(0.9), vibrantGreen.withOpacity(0.9)],
          stops: const [0, 1],
          center: Alignment.topRight,
        ),
      ),
      child: Stack(children: [
        SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: IconButton(
                        icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
                        onPressed: context.pop,
                      ),
                    ),
                    Expanded(
                      child: Text("TRKR COACH",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ],
                ),
                ExerciseLogListView(
                  exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: widget.template.exerciseTemplates),
                  previewType: RoutinePreviewType.template,
                ),
              ],
            ),
          ),
        ),
        if (_loading) const OverlayBackground()
      ]),
    ));
  }

  @override
  void initState() {
    super.initState();
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs.map((exerciseLog) {
      return ExerciseLogViewModel(
          exerciseLog: exerciseLog,
          superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
    }).toList();
  }
}
