import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/dialog_utils.dart';
import 'trkr_coach_widget.dart';
import '../video_bottom_sheet.dart';

class TRKRCoachMessageWidget extends StatelessWidget {

  final String message;

  const TRKRCoachMessageWidget({super.key, required this.message});

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