import 'package:flutter/material.dart';

class LabelContainer extends StatelessWidget {
  final String label;
  final String description;
  final TextStyle labelStyle;
  final TextStyle descriptionStyle;
  final Color dividerColor;
  final bool leftToRight;

  const LabelContainer(
      {super.key,
      required this.label,
      required this.description,
      required this.labelStyle,
      required this.descriptionStyle,
      required this.dividerColor,
      this.leftToRight = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          leftToRight
              ? Text(
                  label,
                  style: labelStyle,
                )
              : SizedBox.shrink(),
          Expanded(
            child: Container(
              height: 1, // height of the divider
              width: double.infinity, // width of the divider (line thickness)
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(5),
              ), // color of the divider
              margin: const EdgeInsets.symmetric(horizontal: 10), // add space around the divider
            ),
          ),
          !leftToRight
              ? Text(
                  label,
                  style: labelStyle,
                )
              : SizedBox.shrink()
        ]),
        Padding(
            padding: EdgeInsets.only(top: 6, right: 10),
            child: Text(
              description,
              style: descriptionStyle,
            ))
      ],
    );
  }
}
