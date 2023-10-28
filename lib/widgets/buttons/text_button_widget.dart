import 'package:flutter/material.dart';

import '../../app_constants.dart';

class CTextButton extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final Color? buttonColor;

  const CTextButton({super.key, required this.onPressed, required this.label, this.buttonColor = tealBlueLight});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(buttonColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
        onPressed: onPressed,
        child: Text(label, textAlign: TextAlign.start, style: Theme.of(context).textTheme.labelLarge));
  }
}
