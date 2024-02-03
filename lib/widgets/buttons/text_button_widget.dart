import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';

class CTextButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final String loadingLabel;
  final bool loading;
  final Color? buttonColor;
  final Color? buttonBorderColor;
  final EdgeInsets? padding;
  final VisualDensity? visualDensity;
  final TextStyle? textStyle;

  const CTextButton(
      {super.key,
      required this.onPressed,
      required this.label,
      this.loadingLabel = "loading",
      this.loading = false,
      this.buttonColor,
        this.buttonBorderColor,
      this.padding,
      this.visualDensity = VisualDensity.compact,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = textStyle ?? GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16);
    final buttonColor = this.buttonColor ?? sapphireLight;
    return TextButton(
        style: ButtonStyle(
            visualDensity: visualDensity,
            backgroundColor: MaterialStateProperty.all(buttonColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: buttonBorderColor ?? buttonColor.withOpacity(0.3), width: 2)))),
        onPressed: loading ? null : onPressed,
        child: Container(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loading ? loadingLabel : label, textAlign: TextAlign.start, style: defaultTextStyle),
              loading
                  ? const Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: SizedBox(height: 10, width: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ));
  }
}
