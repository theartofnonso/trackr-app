import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SolidButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final String loadingLabel;
  final bool loading;
  final Color? buttonColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final VisualDensity? visualDensity;

  const SolidButtonWidget(
      {super.key, this.onPressed,
      required this.label,
      this.loadingLabel = "loading",
      this.loading = false,
      this.buttonColor,
      this.textColor,
      this.padding,
      this.visualDensity = VisualDensity.compact});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          visualDensity: visualDensity,
          backgroundColor: WidgetStateProperty.all(buttonColor ?? Colors.transparent),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              return Colors.black.withValues(alpha:0.3); // Defer to the widget's default.
            },
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: Container(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loading ? loadingLabel : label,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600, fontSize: 16, color: textColor ?? Colors.white)),
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
