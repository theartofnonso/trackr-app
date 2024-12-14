import 'package:flutter/material.dart';

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

  Color? _themeBackgroundColor({required bool isDarkMode}) {
    return isDarkMode ? buttonColor?.withOpacity(0.15) : buttonColor;
  }

  Color _defaultBackgroundColor({required bool isDarkMode}) {
    return isDarkMode ? Colors.white.withOpacity(0.15) : Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final action = onPressed ?? onLongPress;

    return TextButton(
        style: ButtonStyle(
          visualDensity: visualDensity,
          backgroundColor: WidgetStateProperty.all(
              _themeBackgroundColor(isDarkMode: isDarkMode) ?? _defaultBackgroundColor(isDarkMode: isDarkMode)),
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
                  style: textStyle ??
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: action != null
                              ? isDarkMode
                                  ? buttonColor
                                  : Colors.black
                              : buttonColor?.withOpacity(0.2))),
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
