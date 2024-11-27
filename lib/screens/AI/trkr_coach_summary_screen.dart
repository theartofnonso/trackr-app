import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../widgets/ai_widgets/trkr_coach_message_widget.dart';

class TRKRCoachSummaryScreen extends StatelessWidget {
  static const routeName = '/trkr_coach_summary_screen';

  final String content;

  const TRKRCoachSummaryScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            sapphireDark80,
            sapphireDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
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
          icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
          onPressed: Navigator.of(context).pop,
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
