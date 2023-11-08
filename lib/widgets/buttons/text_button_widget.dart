import 'package:flutter/material.dart';

import '../../app_constants.dart';

class CTextButton extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final Color? buttonColor;
  final TextStyle? textStyle;

  const CTextButton({super.key, required this.onPressed, required this.label, this.buttonColor = tealBlueLight, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            backgroundColor: MaterialStateProperty.all(buttonColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)))),
        onPressed: onPressed,
        child: Text(label, textAlign: TextAlign.start, style: textStyle ?? Theme.of(context).textTheme.labelLarge));
  }
}
