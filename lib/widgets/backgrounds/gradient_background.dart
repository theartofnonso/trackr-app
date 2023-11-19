import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';

class GradientBackground extends StatelessWidget {
  final double height;
  final Alignment begin;
  final Alignment end;
  final Color color;

  const GradientBackground(
      {Key? key, required this.height, required this.begin, required this.end, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [
            color,
            color,
            tealBlueDark,
          ],
        ),
      ),
    );
  }
}
