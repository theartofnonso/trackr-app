import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/label_divider.dart';

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
      decoration: const BoxDecoration(
        gradient: SweepGradient(
          colors: [vibrantBlue, vibrantGreen],
          stops: [0, 1],
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
                    icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.black, size: 28),
                    onPressed: context.pop,
                  ),
                  Expanded(
                    child: Text("TRKR COACH",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
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
              const SizedBox(height: 20),
              LabelDivider(
                label: "Optimise ${widget.template.name}",
                labelColor: Colors.black,
                dividerColor: Colors.black.withOpacity(0.3),
              ),
              const SizedBox(height: 2),
              ListTile(
                dense: true,
                title: Text("Endurance, Strength, Hypertrophy?",
                    style: GoogleFonts.ubuntu(
                        color: Colors.black.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
                trailing: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.black, size: 18),
              ),
              Divider(
                height: 0.5,
                color: Colors.black.withOpacity(0.2),
              ),
              ListTile(
                title: Text("Crunch workout time",
                    style: GoogleFonts.ubuntu(
                        color: Colors.black.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
                trailing: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.black, size: 18),
              ),
              Divider(
                height: 0.5,
                color: Colors.black.withOpacity(0.2),
              ),
              ListTile(
                title: Text("Focus on Full, Upper, Lower or Core",
                    style: GoogleFonts.ubuntu(
                        color: Colors.black.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
                trailing: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.black, size: 18),
              ),
              Divider(
                height: 0.5,
                color: Colors.black.withOpacity(0.2),
              ),
              ListTile(
                title: Text("Optimise for muscle group",
                    style: GoogleFonts.ubuntu(
                        color: Colors.black.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
                trailing: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.black, size: 18),
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
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs.map((exerciseLog) {
      return ExerciseLogViewModel(
          exerciseLog: exerciseLog,
          superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
    }).toList();
  }
}
