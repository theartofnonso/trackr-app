import 'package:flutter/material.dart';

import '../../app_constants.dart';

class CTextButton extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final String loadingLabel;
  final bool loading;
  final Color? buttonColor;
  final TextStyle? textStyle;

  const CTextButton(
      {super.key,
      required this.onPressed,
      required this.label,
      this.loadingLabel = "loading",
      this.loading = false,
      this.buttonColor = tealBlueLight,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            backgroundColor: MaterialStateProperty.all(buttonColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)))),
        onPressed: loading ? () {} : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loading ? loadingLabel : label,
                textAlign: TextAlign.start, style: textStyle ?? Theme.of(context).textTheme.labelLarge),
            loading
                ? const Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: SizedBox(height: 10, width: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const SizedBox.shrink()
          ],
        ));
  }
}
