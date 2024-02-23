import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainer extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final RichText? richDescription;
  final String description;
  final Widget? trailingIcon;
  final Color color;

  const InformationContainer(
      {super.key, required this.leadingIcon, required this.title, this.trailingIcon, this.description = "", required this.color, this.richDescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            leadingIcon,
            const SizedBox(width: 6),
            Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            trailingIcon ?? const SizedBox(),
          ]),
          const SizedBox(height: 8),
          richDescription ?? Text(description, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
