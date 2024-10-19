import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/strings/ai_prompts.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../../controllers/routine_template_controller.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../enums/routine_preview_type_enum.dart';
import '../../../openAI/open_ai.dart';
import '../../../utils/routine_utils.dart';
import '../../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../../widgets/routine/preview/exercise_log_listview.dart';

class TRKRCoachContextScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  const TRKRCoachContextScreen({super.key});

  @override
  State<TRKRCoachContextScreen> createState() => _TRKRCoachContextScreenState();
}

class _TRKRCoachContextScreenState extends State<TRKRCoachContextScreen> {
  bool _loading = false;

  late TextEditingController _textEditingController;

  RoutineTemplateDto? _routineTemplate;

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineTemplate = _routineTemplate;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBar(positiveAction: _saveTemplate, canPerformPositiveAction: routineTemplate != null),
              routineTemplate != null
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: ExerciseLogListView(
                          exerciseLogs: exerciseLogsToViewModels(exerciseLogs: routineTemplate.exerciseTemplates),
                          previewType: RoutinePreviewType.ai,
                        ),
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 12,
                          ),
                          _HeroWidget(),
                          const Spacer()
                        ],
                      ),
                    ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.white10)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.white30)),
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: "Describe your workout",
                          hintStyle:
                              GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400)),
                      maxLines: null,
                      cursorColor: Colors.white,
                      showCursor: true,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: _runMessage,
                    icon: const FaIcon(FontAwesomeIcons.paperPlane),
                    color: Colors.white,
                  )
                ],
              ),
            ],
          ),
        ),
        if (_loading) const TRKRLoadingScreen()
      ]),
    ));
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  void _runMessage() async {
    final userPrompt = _textEditingController.text;

    if(userPrompt.isNotEmpty) {
      _dismissKeyboard();
      _toggleLoadingState();
      _clearTextEditing();

      final routineTemplate =
      await runFunctionMessage(system: defaultSystemInstruction, user: userPrompt, context: context);
      setState(() {
        _routineTemplate = routineTemplate;
      });

      _toggleLoadingState();
    }
  }

  void _clearTextEditing() {
    setState(() {
      _textEditingController.clear();
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _saveTemplate() async {
    final routineTemplate = _routineTemplate;
    if (routineTemplate != null) {
      final templateController = Provider.of<RoutineTemplateController>(context, listen: false);
      final template = await templateController.saveTemplate(templateDto: routineTemplate);
      if (template != null) {
        if (mounted) {
          context.pop();
        }
      }
    }
  }
}

class _AppBar extends StatelessWidget {
  final VoidCallback positiveAction;
  final bool canPerformPositiveAction;

  const _AppBar({required this.positiveAction, this.canPerformPositiveAction = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
        Expanded(
          child: Text("TRKR Coach".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
        canPerformPositiveAction
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 28),
                onPressed: positiveAction,
              )
            : const IconButton(
                icon: SizedBox.shrink(),
                onPressed: null,
              )
      ],
    );
  }
}

class _HeroWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TRKRCoachWidget(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
                text: "Hey there! TRKR Coach",
                style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
                children: <TextSpan>[
                  TextSpan(
                      text: " ",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: "TRKR Coach",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  TextSpan(
                      text: " ",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: "can help you create awesome workouts",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: ".",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: " ",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                  TextSpan(
                      text: "Start with the suggestions below.",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("Create a fullbody workout",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("Help me create a back and biceps workout",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("I need a machine-only workout",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        )
      ]),
    );
  }
}
