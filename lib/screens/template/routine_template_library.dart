import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoutineTemplateLibrary extends StatelessWidget {
  const RoutineTemplateLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          const SizedBox(height: 20),
          Text(
              "Explore our curated workouts, from daily splits to focusing on particular muscle groups and classic routines",
              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
          
        ]),
      ),
    );
  }
}
