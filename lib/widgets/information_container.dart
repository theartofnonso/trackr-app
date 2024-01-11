import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationContainer extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final Color color;

  const InformationContainer(
      {super.key, required this.icon, required this.title, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            icon,
            const SizedBox(width: 6),
            Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
