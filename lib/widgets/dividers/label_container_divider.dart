import 'package:flutter/material.dart';

enum LabelAlignment { left, center, right }

class LabelContainerDivider extends StatelessWidget {
  final String label;
  final String description;
  final TextStyle labelStyle;
  final Widget? child;
  final TextStyle descriptionStyle;
  final Color dividerColor;
  final LabelAlignment labelAlignment;

  const LabelContainerDivider(
      {super.key,
      required this.label,
      required this.description,
      required this.labelStyle,
      this.child,
      required this.descriptionStyle,
      required this.dividerColor,
      this.labelAlignment = LabelAlignment.left});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelAlignment == LabelAlignment.left)
          _LeftAlignment(
              dividerColor: dividerColor,
              child: Text(
                label,
                style: labelStyle,
              )),
        if (labelAlignment == LabelAlignment.center)
          _CenterAlignment(
              dividerColor: dividerColor,
              child: Text(
                label,
                style: labelStyle,
              )),
        if (labelAlignment == LabelAlignment.right)
          _RightAlignment(
              dividerColor: dividerColor,
              child: Text(
                label,
                style: labelStyle,
              )),
        child ?? SizedBox.shrink(),
        Padding(
            padding: EdgeInsets.only(top: 6, right: 10),
            child: Text(
              description,
              style: descriptionStyle,
              textAlign: labelAlignment == LabelAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
            ))
      ],
    );
  }
}

class _LeftAlignment extends StatelessWidget {
  final Widget child;
  final Color dividerColor;

  const _LeftAlignment({required this.child, required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      child,
      Expanded(
        child: Container(
          height: 1, // height of the divider
          width: double.infinity, // width of the divider (line thickness)
          decoration: BoxDecoration(
            color: dividerColor,
          ), // color of the divider
          margin: const EdgeInsets.symmetric(
              horizontal: 10), // add space around the divider
        ),
      ),
    ]);
  }
}

class _CenterAlignment extends StatelessWidget {
  final Widget child;
  final Color dividerColor;

  const _CenterAlignment({required this.child, required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    final divider = Expanded(
      child: Container(
        height: 1, // height of the divider
        width: double.infinity, // width of the divider (line thickness)
        decoration: BoxDecoration(
          color: dividerColor,
          borderRadius: BorderRadius.circular(2),
        ), // color of the divider
        margin: const EdgeInsets.symmetric(
            horizontal: 10), // add space around the divider
      ),
    );
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [divider, child, divider]);
  }
}

class _RightAlignment extends StatelessWidget {
  final Widget child;
  final Color dividerColor;

  const _RightAlignment({required this.child, required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Container(
          height: 1, // height of the divider
          width: double.infinity, // width of the divider (line thickness)
          decoration: BoxDecoration(
            color: dividerColor,
          ), // color of the divider
          margin: const EdgeInsets.symmetric(
              horizontal: 10), // add space around the divider
        ),
      ),
      child
    ]);
  }
}
