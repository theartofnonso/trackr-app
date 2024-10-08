import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/open_ai_controller.dart';
import 'package:tracker_app/widgets/trkr_widgets/trkr_coach_widget.dart';

import '../../../dtos/routine_template_dto.dart';
import '../../../widgets/backgrounds/overlay_background.dart';
import '../../../widgets/expandable_textfield.dart';

class RoutineTemplateAIContextScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  const RoutineTemplateAIContextScreen({super.key});

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
              const SizedBox(height: 8,),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const TRKRCoachWidget(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Hey Nonso, it looks like TRKR couldn't find your Recovery score for today. Is there a specific time or metric you're curious about? Let TRKR know so it can help you better.",
                    style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              ]),
              const Spacer(),
              ExpandableTextFieldWidget(
                onChanged: (String) {},
                onClear: () {},
                hintText: '',
                controller: TextEditingController(),
              ),
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
  }

  void _addMessage() {
    final userInstructions = _textEditingController.text.trim();

    if (userInstructions.isNotEmpty) {
      _toggleLoadingState();

      final exercises = _template.exerciseTemplates.map((template) => template.exercise.id);

      final additionalInstructions = "Strictly consider ${exercises.join(",")} when providing suggestions.";
      final messageInstructions = '$userInstructions. $additionalInstructions';

      Provider.of<OpenAIController>(context, listen: false).addMessage(prompt: messageInstructions).then((_) {
        _runAI();
      });
    }
  }

  void _runAI() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final controller = Provider.of<OpenAIController>(context, listen: false);
      if (controller.isRunComplete) {
        _timer?.cancel();
        _toggleLoadingState();
        controller.processMessages();
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
