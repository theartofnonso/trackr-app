import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors.dart';

class InformationContainer extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final Widget? richDescription;
  final String description;
  final Widget? trailingIcon;
  final Color color;

  const InformationContainer(
      {super.key,
      required this.leadingIcon,
      required this.title,
      this.trailingIcon,
      this.description = "",
      required this.color,
      this.richDescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(radiusMD)),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(),
            style:
                GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w700)),
        richDescription ??
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(description,
                  style: GoogleFonts.ubuntu(
                      fontSize: 14, fontWeight: FontWeight.w400, height: 2)),
            ),
      ]),
    );
  }
}
