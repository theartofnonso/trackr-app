import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainerLite extends StatelessWidget {
  final Widget? icon;
  final String content;
  final Color? color;
  final RichText? richText;
  final void Function()? onTap;

  const InformationContainerLite({super.key, this.icon, required this.content, required this.color, this.richText, this.onTap});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? color?.withValues(alpha: 0.1) : color, borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
              child: richText ?? Text(content,
                  style: GoogleFonts.ubuntu(
                      fontSize: 12,
                      height: 1.4,
                      color: isDarkMode ? color : Colors.black,
                      fontWeight: FontWeight.w600))),
          if(onTap != null)
            GestureDetector(onTap: onTap, child: FaIcon(FontAwesomeIcons.solidCircleXmark, color: isDarkMode ? color : Colors.black,))
        ],
      ),
    );
  }
}
