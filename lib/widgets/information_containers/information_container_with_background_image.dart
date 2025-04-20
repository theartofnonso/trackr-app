import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/buttons/solid_button_widget.dart';

import '../../colors.dart';

class BackgroundInformationContainer extends StatelessWidget {
  final String content;
  final Color? containerColor;
  final TextStyle? textStyle;
  final String image;
  final String ctaContent;

  const BackgroundInformationContainer(
      {super.key, required this.content, this.containerColor, this.textStyle, required this.image, required this.ctaContent});

  @override
  Widget build(BuildContext context) {
    final color = containerColor ?? sapphireDark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 120,
        child: Stack(children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withValues(alpha: 0.6),
                  sapphireLighter.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(content,
                    style: textStyle ??
                        GoogleFonts.ubuntu(
                            fontSize: 12, height: 1.4, color: containerColor ?? Colors.white, fontWeight: FontWeight.w500)),
                  SolidButtonWidget(label: ctaContent, buttonColor: containerColor),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
