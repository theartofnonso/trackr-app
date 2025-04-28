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
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black,
        offset: Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ],
  });

  /// The widgets to paint. Must contain **≥ 1** entry.
  final List<Widget> children;

  /// How far (in logical pixels) to drop the last child (positive = down)
  final double depthOffset;

  /// Mirrors the same parameter on [Stack]
  final AlignmentGeometry alignment;

  /// Same as [Stack.clipBehavior]
  final Clip clipBehavior;

  /// Padding applied to all children except the last
  final EdgeInsetsGeometry basePadding;

  /// Background color for the elevated last child
  final Color backgroundColor;

  /// Border radius for the last child's container
  final BorderRadiusGeometry borderRadius;

  /// Box shadows for the last child's container
  final List<BoxShadow> boxShadow;

  @override
  Widget build(BuildContext context) {

    final baseChildren = children.sublist(0, children.length - 1);
    final lastChild = children.last;

    return Stack(
      alignment: alignment,
      clipBehavior: clipBehavior,
      children: [
        // Base children with padding
        ...baseChildren.map((child) => Padding(
          padding: basePadding,
          child: child,
        )),

        // Elevated last child
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
        ),
      ],
    );
  }
}