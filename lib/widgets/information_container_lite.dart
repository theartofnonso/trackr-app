import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainerLite extends StatelessWidget {
  final Widget? icon;
  final String content;
  final Color? color;

  const InformationContainerLite({super.key, this.icon, required this.content, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: color != null ? color?.withOpacity(0.2) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          icon ??
              FaIcon(
                FontAwesomeIcons.exclamation,
                color: color,
                size: 16,
              ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(content,
                  style: GoogleFonts.ubuntu(
                      fontSize: 12, height: 1.4, color: color ?? Colors.white, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
