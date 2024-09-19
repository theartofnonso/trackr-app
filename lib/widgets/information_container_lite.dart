import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainerLite extends StatelessWidget {
  final String content;
  final Color color;

  const InformationContainerLite({super.key, required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          FaIcon(FontAwesomeIcons.exclamation, color: color, size: 16,),
          const SizedBox(width: 14),
          Expanded(child: Text(content, style: GoogleFonts.montserrat(fontSize: 12, height: 1.4, color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
