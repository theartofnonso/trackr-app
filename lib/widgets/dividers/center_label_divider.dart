import 'package:flutter/material.dart';

class CenterLabelDivider extends StatelessWidget {
  final String label;
  final TextStyle style;
  final bool shouldCapitalise;
  final Color dividerColor;

  const CenterLabelDivider(
      {super.key, required this.label, required this.style, this.shouldCapitalise = false, required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Container(
          height: 0.8, // height of the divider
          width: double.infinity, // width of the divider (line thickness)
          color: dividerColor, // color of the divider
          margin: const EdgeInsets.symmetric(horizontal: 16), // add space around the divider
        ),
      ),
      Text(
        label,
        style: style,
      ),
      Expanded(
        child: Container(
          height: 1, // height of the divider
          width: double.infinity, // width of the divider (line thickness)
          color: dividerColor, // color of the divider
          margin: const EdgeInsets.symmetric(horizontal: 16), // add space around the divider
        ),
      ),
    ]);
  }
}
