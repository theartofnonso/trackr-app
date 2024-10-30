import 'package:flutter/cupertino.dart';

import '../../colors.dart';

class TRKRCoachTextWidget extends StatelessWidget {
  const TRKRCoachTextWidget(this.text, {
    super.key,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(colors: [
      vibrantBlue,
      vibrantGreen // End color
    ]);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
