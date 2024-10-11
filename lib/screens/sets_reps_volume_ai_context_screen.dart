import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/ai_widgets/trkr_coach_message_widget.dart';

class SetsRepsVolumeAIContextScreen extends StatelessWidget {
  static const routeName = '/sets_reps_volume_ai_context_screen';

  final String content;

  const SetsRepsVolumeAIContextScreen({super.key, required this.content});

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
      child: SafeArea(
        minimum: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AppBar(),
            const SizedBox(
              height: 8,
            ),
            Expanded(child: SingleChildScrollView(child: TRKRCoachMessageWidget(message: content)))
          ],
        ),
      ),
    ));
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
          onPressed: () {},
        )
      ],
    );
  }
}
