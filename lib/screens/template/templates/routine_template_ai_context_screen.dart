import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/open_ai_controller.dart';
import 'package:tracker_app/widgets/trkr_widgets/trkr_coach_widget.dart';

import '../../../widgets/backgrounds/overlay_background.dart';

class RoutineTemplateAIContextScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  const RoutineTemplateAIContextScreen({super.key});

  @override
  State<RoutineTemplateAIContextScreen> createState() => _RoutineTemplateAIContextScreenState();
}

class _RoutineTemplateAIContextScreenState extends State<RoutineTemplateAIContextScreen> {

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
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const TRKRCoachWidget(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Hey Nonso, it looks like TRKR couldn't find your Recovery score for today. Is there a specific time or metric you're curious about? Let TRKR know so it can help you better.",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                  )
                ]),
              ),
              const Spacer(),
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
                          hintText: "Ask TRKR Coach",
                          hintStyle: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400)),
                      maxLines: null,
                      cursorColor: Colors.white,
                      showCursor: true,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: _addMessage,
                    icon: const FaIcon(FontAwesomeIcons.paperPlane),
                    color: Colors.white,
                  )
                ],
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
    _dismissKeyboard();

    final userInstructions = _textEditingController.text.trim();

    if (userInstructions.isNotEmpty) {
      _toggleLoadingState();

      Provider.of<OpenAIController>(context, listen: false).addMessage(prompt: userInstructions).then((_) {
        _runAI();
      });

      setState(() {
        _textEditingController.clear();
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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}
