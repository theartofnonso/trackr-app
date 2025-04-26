import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A semicircular gauge whose gradient colors rotate slowly with the gauge
/// positioned above the label.
///
/// ```dart
/// const AnimatedGauge(value: 134, min: 0, max: 200)
/// ```
class AnimatedGauge extends StatefulWidget {
  const AnimatedGauge({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.size = 280,
    this.stroke = 24,
    this.rotationPeriod = const Duration(seconds: 6),
    this.unit = 'kg de co2',
    this.labelFontSize = 66,
    this.unitFontSize = 18,
    this.labelColor = const Color(0xFF262335),
    this.unitColor = const Color(0xFF5B5568),
  });

  final double value;
  final double min;
  final double max;
  /// Diameter of the imaginary circle that hosts the 180-degree arc.
  final double size;
  /// Thickness of the colored stroke.
  final double stroke;
  /// Time it takes for the gradient to make one full revolution.
  final Duration rotationPeriod;
  /// Unit text displayed below the value.
  final String unit;
  /// Font size for the main value label.
  final double labelFontSize;
  /// Font size for the unit text.
  final double unitFontSize;
  /// Color for the main value label.
  final Color labelColor;
  /// Color for the unit text.
  final Color unitColor;

  @override
  State<AnimatedGauge> createState() => _AnimatedGaugeState();
}

class _AnimatedGaugeState extends State<AnimatedGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.rotationPeriod)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size / 2 + widget.stroke + 80, // Extra space for label
      child: Stack(
        children: [
          // Gauge positioned above the label
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _GaugePainter(
                    value: widget.value,
                    min: widget.min,
                    max: widget.max,
                    stroke: widget.stroke,
                    gradientRotation: _ctrl.value, // 0 → 1 (0-360°)
                  ),
                );
              },
            ),
          ),

          // Label positioned below the gauge
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _GaugeLabel(
              value: widget.value,
              unit: widget.unit,
              labelFontSize: widget.labelFontSize,
              unitFontSize: widget.unitFontSize,
              labelColor: widget.labelColor,
              unitColor: widget.unitColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the colored arc + knob.
class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.stroke,
    required this.gradientRotation,
  });

  final double value, min, max, stroke, gradientRotation;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height - stroke / 2);
    final Rect sweepRect =
    Rect.fromCircle(center: center, radius: radius + stroke / 2);

    // Draw background track (gray arc)
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = Colors.grey.withOpacity(0.15);

    final Path backgroundArc = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi,
      );
    canvas.drawPath(backgroundArc, backgroundPaint);

    // Gradient rotates by [gradientRotation] * 360°
    final shader = SweepGradient(
      startAngle: math.pi,               // left-most point
      endAngle: math.pi * 3,             // completes full circle
      transform: GradientRotation(gradientRotation * 2 * math.pi),
      colors: const [
        Color(0xFF5733FF), // deep indigo
        Color(0xFF9B3AFF), // purple
        Color(0xFFE6427A), // magenta-pink
        Color(0xFFFA709A), // salmon
        Color(0xFF5733FF), // loop back
      ],
    ).createShader(sweepRect);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..shader = shader;

    // Calculate the active portion of the arc based on value
    final percent = (value - min) / (max - min);
    final activeAngle = percent.clamp(0, 1) * math.pi;

    // Draw active portion of the arc
    final Path activeArc = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        activeAngle,
      );
    canvas.drawPath(activeArc, trackPaint);

    // ---- knob position ----------------------------------------------------
    final knobAngle = math.pi + (percent.clamp(0, 1) * math.pi);
    final knobOffset = Offset(
      center.dx + radius * math.cos(knobAngle),
      center.dy + radius * math.sin(knobAngle),
    );

    // Draw shadow under knob
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(knobOffset, stroke * .45, shadowPaint);

    // Draw white knob
    final knobPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(knobOffset, stroke * .45, knobPaint);

    // Thin outline on knob for contrast
    canvas.drawCircle(
      knobOffset,
      stroke * .45,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black12
        ..strokeWidth = 2,
    );

    // Add a subtle inner shadow to the knob
    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.black.withOpacity(0.05);
    canvas.drawCircle(knobOffset, stroke * .3, innerShadowPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.gradientRotation != gradientRotation ||
          old.value != value ||
          old.min != min ||
          old.max != max;
}

/// Label displaying the value and unit.
class _GaugeLabel extends StatelessWidget {
  const _GaugeLabel({
    required this.value,
    required this.unit,
    required this.labelFontSize,
    required this.unitFontSize,
    required this.labelColor,
    required this.unitColor,
  });

  final double value;
  final String unit;
  final double labelFontSize;
  final double unitFontSize;
  final Color labelColor;
  final Color unitColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            height: 1,
            fontSize: labelFontSize,
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: unitFontSize,
            letterSpacing: .2,
            color: unitColor,
          ),
        ),
      ],
    );
  }
}