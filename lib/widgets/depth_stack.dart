import 'package:flutter/material.dart';

class DepthStack extends StatelessWidget {
  const DepthStack({
    super.key,
    required this.children,
    this.depthOffset = 8.0,
    this.alignment = Alignment.topLeft,
    this.clipBehavior = Clip.none,
    this.basePadding = const EdgeInsets.symmetric(horizontal: 6),
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final List<Widget> children;
  final double depthOffset;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;
  final EdgeInsetsGeometry basePadding;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    assert(children.isNotEmpty, 'DepthStack requires at least one child');

    final hasMultipleChildren = children.length > 1;
    final baseChildren = hasMultipleChildren ? children.sublist(0, children.length - 1) : [];
    final lastChild = children.last;

    final boxShadow = [
      BoxShadow(
        color: isDarkMode ? Colors.black : Colors.grey.shade300,
        offset: Offset(0, 4),
        blurRadius: isDarkMode ? 10 : 2.8,
        spreadRadius: 4,
      ),
    ];

    return Stack(
      alignment: alignment,
      clipBehavior: clipBehavior,
      children: [
        // Base children with padding
        ...baseChildren.map((child) => Padding(
          padding: basePadding,
          child: child,
        )),
        // Handle last child based on number of children
        if (hasMultipleChildren)
          Positioned(
            left: 0,
            right: 0,
            top: depthOffset,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
                boxShadow: boxShadow,
              ),
              child: lastChild,
            ),
          )
        else
          Padding(
            padding: basePadding,
            child: Container(
              margin: EdgeInsets.only(top: depthOffset),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
                boxShadow: boxShadow,
              ),
              child: lastChild,
            ),
          ),
      ],
    );
  }
}