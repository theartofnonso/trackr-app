import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/backgrounds/gradient_widget.dart';

import '../../app_constants.dart';

class RoutineLogEmptyState extends StatelessWidget {
  const RoutineLogEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                tileColor: sapphireLight,
                dense: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                title: Text("Legs Day 1", style: Theme.of(context).textTheme.labelLarge),
                subtitle: Text("3 exercises",
                    style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                trailing: Text("59m 39s",
                    style: GoogleFonts.montserrat(
                        color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: sapphireLight,
                dense: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                title: Text("Push Day", style: Theme.of(context).textTheme.labelLarge),
                subtitle: Text("5 exercises",
                    style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                trailing: Text("47m 39s",
                    style: GoogleFonts.montserrat(
                        color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
