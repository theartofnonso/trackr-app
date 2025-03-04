import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainerLite extends StatelessWidget {
  final Widget? icon;
  final String content;
  final Color? color;
  final RichText? richText;

  const InformationContainerLite({super.key, this.icon, required this.content, required this.color, this.richText});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? color?.withValues(alpha: 0.1) : color, borderRadius: BorderRadius.circular(5)),
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
              child: richText ?? Text(content,
                  style: GoogleFonts.ubuntu(
                      fontSize: 12,
                      height: 1.4,
                      color: isDarkMode ? color : Colors.black,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
