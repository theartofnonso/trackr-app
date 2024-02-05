import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class OutlineListTile extends StatelessWidget {
  final String title;
  final String? trailing;
  final void Function() onTap;

  const OutlineListTile({super.key, required this.onTap, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {

    final trailing = this.trailing;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: sapphireLight, // Background color
          width: 2, // Border width
        ),
        borderRadius: BorderRadius.circular(5), // Border radius
      ),
      child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          splashColor: sapphireLighter,
          onTap: onTap,
          title: Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          trailing: trailing != null ? Text(trailing, style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14)) : null),
    );
  }
}
