import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class NoListEmptyState extends StatelessWidget {

  final Widget icon;
  final String message;

  const NoListEmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              icon,
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                      color: Colors.white38,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600))
            ])),
      ),
    );
  }
}
