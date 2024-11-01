import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../colors.dart';

class METRatingScreen extends StatefulWidget {
  const METRatingScreen({super.key, this.opacity = 0.6, this.action});

  final double opacity;
  final VoidCallback? action;

  @override
  State<METRatingScreen> createState() => _METRatingScreenState();
}

class _METRatingScreenState extends State<METRatingScreen> {

  double _rating = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: sapphireDark.withOpacity(widget.opacity),
        child: Stack(
          children: [
            Center(
              child: Slider(value: _rating, onChanged: onChanged, min: 1, max: 10, thumbColor: vibrantGreen),
            ),
          ],
        ));
  }

  void onChanged(double value) {

    if(value > 5) {
      HapticFeedback.heavyImpact();
    } else if(value < 5 && value > 3) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _rating = value;
    });
  }
}
