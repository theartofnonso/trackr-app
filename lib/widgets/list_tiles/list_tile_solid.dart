import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';

class SolidListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailingSubtitle;
  final String trailing;
  final void Function() onTap;
  final EdgeInsetsGeometry? margin;
  final Color? tileColor;

  const SolidListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailingSubtitle,
    required this.trailing,
    required this.onTap,
    this.margin,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    final trailingSubtitle = this.trailingSubtitle;
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: Container(
        margin: margin,
        child: ListTile(
          tileColor: tileColor,
          onTap: onTap,
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Text(title,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Row(
            children: [
              Text(subtitle,
                  style: GoogleFonts.montserrat(
                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(width: 8),
              if (trailingSubtitle != null) trailingSubtitle
            ],
          ),
          trailing: Text(trailing,
              style: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
        ),
      ),
    );
  }
}
