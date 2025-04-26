
import 'package:flutter/material.dart';

class DepthStack extends StatelessWidget {

  const DepthStack({
    super.key,
    required this.children,
    this.depthOffset = 0.3,
    this.alignment = Alignment.topLeft,
    this.clipBehavior = Clip.none,
  });

  /// The widgets to paint. Must contain **≥ 1** entry.
  final List<Widget> children;

  /// How far (in logical pixels) to drop the last child.
  final double depthOffset;

  /// Mirrors the same parameter on [Stack] so this can be a
  /// 1-for-1 replacement when you need the depth effect.
  final AlignmentGeometry alignment;

  /// Same as [Stack.clipBehavior].
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    // Everything except the last child
    final base = children.sublist(0, children.length - 1).map((child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: child,
    ));

    // The child we’ll push downward
    final last = children.last;

    return Stack(
      alignment: alignment,
      clipBehavior: clipBehavior,
      children: [
        ...base,
        // Move the last child down by depthOffset (positive = down)
        Positioned(
          left: 0,
          right: 0,
          top: -depthOffset,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45), // shadow color
                    offset: const Offset(0, 8), // x, y
                    blurRadius: 10, // soften the edge
                    spreadRadius: 1, // extend the shadow
                  ),
                ],
              ),
              child: last),
        ),
      ],
    );
  }
}
