import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/open_ai_controller.dart';
import 'package:tracker_app/dtos/routine_template_dto.dart';
import 'package:tracker_app/enums/open_ai_enums.dart';
import 'package:tracker_app/widgets/trkr_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/video_bottom_sheet.dart';

import '../../../utils/dialog_utils.dart';
import '../../../widgets/backgrounds/overlay_background.dart';

class RoutineTemplateAIContextScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  final RoutineTemplateDto? template;

  const RoutineTemplateAIContextScreen({super.key, this.template});

  @override
  State<RoutineTemplateAIContextScreen> createState() => _RoutineTemplateAIContextScreenState();
}

class _RoutineTemplateAIContextScreenState extends State<RoutineTemplateAIContextScreen> {
  late Function _onDisposeCallback;

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
    final template = widget.template;

    final controller = Provider.of<OpenAIController>(context, listen: true);

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
              const _AppBar(),
              const SizedBox(
                height: 8,
              ),
              if (controller.message.isEmpty)
                template != null ? _OptimiseHeroWidget(template: template) : _HeroWidget(),
              if (controller.message.isNotEmpty)
                Expanded(child: SingleChildScrollView(child: _TRKRCoachMessageWidget(message: controller.message))),
              controller.message.isNotEmpty ? const SizedBox(height: 16) : const Spacer(),
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
                          hintText: "Start typing",
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
                    onPressed: _addTemplateMessage,
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
    _onDisposeCallback = Provider.of<OpenAIController>(context, listen: false).onClear;
  }

  void addMessage() {
    final template = widget.template;
    if (template != null) {
      _addTemplateMessage();
    } else {
      _addGenericMessage();
    }
  }

  void _addTemplateMessage() {
    _dismissKeyboard();

    final userInstructions = _textEditingController.text.trim();

    final templateJson = jsonEncode(widget.template?.toJson());

    final StringBuffer buffer = StringBuffer();

    buffer.writeln("Using the following workout");
    buffer.writeln(templateJson);
    buffer.writeln(userInstructions);

    final completeInstructions = buffer.toString();

    if (userInstructions.isNotEmpty) {
      _toggleLoadingState();

      Provider.of<OpenAIController>(context, listen: false)
          .addMessage(prompt: completeInstructions, mode: OpenAiEnums.template)
          .then((_) {
        print("About to check run status");
        _runAI();
      });

      setState(() {
        _textEditingController.clear();
      });
    }
  }

  void _addGenericMessage() {
    _dismissKeyboard();

    final userInstructions = _textEditingController.text.trim();

    if (userInstructions.isNotEmpty) {
      _toggleLoadingState();

      Provider.of<OpenAIController>(context, listen: false)
          .addMessage(prompt: userInstructions, mode: OpenAiEnums.template)
          .then((_) {
        print("About to check run status");
        _runAI();
      });

      setState(() {
        _textEditingController.clear();
      });
    }
  }

  void _runAI() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print("Starting timer");
      final controller = Provider.of<OpenAIController>(context, listen: false);
      if (controller.isRunComplete) {
        print("Timer has ended");
        _timer?.cancel();
        _toggleLoadingState();
        controller.processMessages();
      } else {
        print("Timer is still running");
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
    _onDisposeCallback();
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

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
        IconButton(
          icon: const SizedBox.shrink(),
          onPressed: context.pop,
        )
      ],
    );
  }
}

class _OptimiseHeroWidget extends StatelessWidget {
  final RoutineTemplateDto template;

  const _OptimiseHeroWidget({
    required this.template,
  });

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
                text: "Hey there! TRKR Coach can help you optimise",
                style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
                children: <TextSpan>[
                  const TextSpan(text: " "),
                  TextSpan(
                      text: template.name,
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const TextSpan(text: ". "),
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
              child: Text("Optimise for a specific goal ",
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
              child: Text("Reduce time spent when training",
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
              child: Text("Focus on particular muscle group",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        )
      ]),
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
                text: "Hey there! TRKR Coach can help you optimise your fitness.",
                style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
                children: <TextSpan>[
                  const TextSpan(text: " "),
                  TextSpan(
                      text: "Start with the suggestions below.",
                      style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("How to train for hypertrophy",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("Optimal rep range to build muscle",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white10.withOpacity(0.1), // Background color of the container
                borderRadius: BorderRadius.circular(5), // Rounded corners
              ),
              child: Text("Recovering from a workout",
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ]),
        )
      ]),
    );
  }
}

class _TRKRCoachMessageWidget extends StatelessWidget {
  final String message;

  const _TRKRCoachMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TRKRCoachWidget(),
        const SizedBox(width: 10),
        Expanded(
            child: MarkdownBody(
          data: message,
          onTapLink: (text, href, title) {
            if (href != null) {
              displayBottomSheet(context: context, child: VideoBottomSheet(url: href));
            }
          },
          styleSheet: MarkdownStyleSheet(
            h1: GoogleFonts.ubuntu(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
            h2: GoogleFonts.ubuntu(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600),
            h3: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            h4: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            h5: GoogleFonts.ubuntu(color: Colors.pink, fontSize: 14, fontWeight: FontWeight.w600),
            h6: GoogleFonts.ubuntu(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
            p: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ))
      ]),
    );
  }
}
