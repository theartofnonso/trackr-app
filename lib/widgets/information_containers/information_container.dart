import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainer extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final Widget? richDescription;
  final String description;
  final Widget? trailingIcon;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const InformationContainer(
      {super.key,
      required this.leadingIcon,
      required this.title,
      this.trailingIcon,
      this.description = "",
      required this.color,
      this.richDescription, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      padding: padding ?? const EdgeInsets.all(12),
      width: double.infinity,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  leadingIcon,
                  const SizedBox(width: 6),
                  Text(title, style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600)),
                ]),
                richDescription ?? Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(description, style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ]),
            ),
            trailingIcon ?? const SizedBox(),
          ]),
    );
  }
}
