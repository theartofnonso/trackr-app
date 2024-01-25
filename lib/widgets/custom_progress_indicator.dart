import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value;
  final String valueText;

  const CustomProgressIndicator({
    Key? key,
    required this.value,
    required this.valueText,
  }) : super(key: key);

  Color get color {
    if (value < 0.3) {
      return Colors.red;
    } else if (value < 0.5) {
      return Colors.orange;
    } else if (value < 0.8) {
      return vibrantBlue;
    } else {
      return vibrantGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              backgroundColor: tealBlueLighter,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                valueText,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "MONTH",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}