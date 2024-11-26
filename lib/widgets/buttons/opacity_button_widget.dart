import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OpacityButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final String label;
  final String loadingLabel;
  final bool loading;
  final Color? buttonColor;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final VisualDensity? visualDensity;

  const OpacityButtonWidget(
      {super.key,
       this.onPressed,
        this.onLongPress,
      required this.label,
      this.loadingLabel = "loading",
      this.loading = false,
      this.buttonColor,
        this.textStyle,
      this.padding,
      this.visualDensity = VisualDensity.compact});

  @override
  Widget build(BuildContext context) {

    final action = onPressed ?? onLongPress;

    return TextButton(
        style: ButtonStyle(
          visualDensity: visualDensity,
          backgroundColor: WidgetStateProperty.all(buttonColor?.withOpacity(0.15) ?? Colors.white.withOpacity(0.15)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              return Colors.black.withOpacity(0.3); // Defer to the widget's default.
            },
          ),
        ),
        onPressed: loading ? null : onPressed,
        onLongPress: loading ? null : onLongPress,
        child: Container(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loading ? loadingLabel : label,
                  textAlign: TextAlign.start,
                  style: textStyle ?? GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: action != null ? buttonColor : buttonColor?.withOpacity(0.2))),
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
