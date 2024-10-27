import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class BackgroundInformationContainer extends StatelessWidget {
  final String content;
  final Color? containerColor;
  final TextStyle? textStyle;
  final String image;

  const BackgroundInformationContainer({super.key, required this.content, this.containerColor, this.textStyle, required this.image});

  @override
  Widget build(BuildContext context) {

    final color = containerColor ?? sapphireDark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 100,
        child: Stack(children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color,
                  color,
                  color.withOpacity(0.4),
                  sapphireLighter.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Text(content,
                style: textStyle ??
                    GoogleFonts.ubuntu(
                        fontSize: 12, height: 1.4, color: containerColor ?? Colors.white, fontWeight: FontWeight.w500)),
          )
        ]),
      ),
    );
  }
}
