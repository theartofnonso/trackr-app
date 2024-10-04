import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SolidListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailingSubtitle;
  final String? trailing;
  final void Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? tileColor;

  const SolidListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingSubtitle,
    this.trailing,
    this.onTap,
    this.margin,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final trailingSubtitle = this.trailingSubtitle;
    final trailing = this.trailing;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: Text(title,
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Row(
          children: [
            if (subtitle != null)
              Text(subtitle,
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(width: 8),
            if (trailingSubtitle != null) trailingSubtitle
          ],
        ),
        trailing: trailing != null ? Text(trailing,
            style: GoogleFonts.ubuntu(
                color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12)) : null,
      ),
    );
  }
}
