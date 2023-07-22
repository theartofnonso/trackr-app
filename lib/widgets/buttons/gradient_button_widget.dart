import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;

  const GradientButton({super.key, 
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Ink(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Colors.white70],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0,),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );

  }
}
