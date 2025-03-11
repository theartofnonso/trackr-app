import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../colors.dart';

class StreakFace extends CustomPainter {
  final Color color;
  final double result;

  StreakFace({required this.color, required this.result});

  @override
  void paint(Canvas canvas, Size size) {
    _drawGradientBackground(canvas, size);
    _drawFace(canvas, size);
  }

  void _drawGradientBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: const Alignment(-0.7, 0.0),
      radius: 1.0,
      colors: [
        color,
        vibrantGreen,
      ],
      stops: const [0.0, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawFace(Canvas canvas, Size size) {
    late Expression expression;
    if (result < 0.3) {
      expression = Expression.angry;
    } else if (result < 0.5) {
      expression = Expression.sad;
    } else if (result < 0.8) {
      expression = Expression.smiling;
    } else {
      expression = Expression.happy;
    }

    switch (expression) {
      case Expression.angry:
        _drawAngryFace(canvas, size);
        break;
      case Expression.sad:
        _drawSadFace(canvas, size);
        break;
      case Expression.smiling:
        _drawSmilingFace(canvas, size);
        break;
      case Expression.happy:
        _drawHappyFace(canvas, size);
        break;
    }
  }

  // ----------------------------------------------------------------
  // 1) ANGRY FACE
  // ----------------------------------------------------------------
  void _drawAngryFace(Canvas canvas, Size size) {
    // Paint for small filled eyes
    final fillPaint = Paint()..color = Colors.black;

    // Paint for arcs (eyebrows & mouth) with round stroke
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Eyes: small filled circles
    final eyeRadius = size.width * 0.02;
    final leftEyeCenter = Offset(size.width * 0.35, size.height * 0.3);
    final rightEyeCenter = Offset(size.width * 0.65, size.height * 0.3);

    canvas.drawCircle(leftEyeCenter, eyeRadius, fillPaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, fillPaint);

    // Angled eyebrows: draw lines with strokeCap.round
    // (You can keep these as lines or arcs—both can have round ends)
    final eyebrowStartLeft = Offset(leftEyeCenter.dx - eyeRadius * 1.5, leftEyeCenter.dy - eyeRadius * 1.8);
    final eyebrowEndLeft   = Offset(leftEyeCenter.dx + eyeRadius * 1.3, leftEyeCenter.dy - eyeRadius * 0.4);
    canvas.drawLine(eyebrowStartLeft, eyebrowEndLeft, strokePaint);

    final eyebrowStartRight = Offset(rightEyeCenter.dx + eyeRadius * 1.5, rightEyeCenter.dy - eyeRadius * 1.8);
    final eyebrowEndRight   = Offset(rightEyeCenter.dx - eyeRadius * 1.3, rightEyeCenter.dy - eyeRadius * 0.4);
    canvas.drawLine(eyebrowStartRight, eyebrowEndRight, strokePaint);

    // Big downward frown (arc) with rounded edges
    final mouthWidth = size.width * 0.35;
    final mouthRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.52),
      width: mouthWidth,
      height: size.height * 0.10,
    );
    // Arc from π to 2π => large frown
    canvas.drawArc(mouthRect, math.pi, math.pi, false, strokePaint);
  }

  // ----------------------------------------------------------------
  // 2) SAD FACE
  // ----------------------------------------------------------------
  void _drawSadFace(Canvas canvas, Size size) {
    // We’ll use stroked arcs for the eyes (with round endpoints).
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final eyeRadius = size.width * 0.03;
    final leftEyeCenter = Offset(size.width * 0.35, size.height * 0.3);
    final rightEyeCenter = Offset(size.width * 0.65, size.height * 0.3);

    final leftEyeRect = Rect.fromCircle(center: leftEyeCenter, radius: eyeRadius);
    final rightEyeRect = Rect.fromCircle(center: rightEyeCenter, radius: eyeRadius);

    // Slight downward arcs for droopy eyes (rounded ends)
    canvas.drawArc(leftEyeRect, 0.2 * math.pi, 0.6 * math.pi, false, strokePaint);
    canvas.drawArc(rightEyeRect, 0.2 * math.pi, 0.6 * math.pi, false, strokePaint);

    // Sad mouth: downward arc with rounded ends
    final mouthRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.45),
      width: size.width * 0.25,
      height: size.height * 0.07,
    );
    canvas.drawArc(mouthRect, 0, math.pi, false, strokePaint);
  }

  // ----------------------------------------------------------------
  // 3) SMILING FACE
  // ----------------------------------------------------------------
  void _drawSmilingFace(Canvas canvas, Size size) {
    // Eyes as upward arcs with rounded edges
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final eyeRadius = size.width * 0.025;
    final leftEyeCenter = Offset(size.width * 0.35, size.height * 0.3);
    final rightEyeCenter = Offset(size.width * 0.65, size.height * 0.3);

    final leftEyeRect = Rect.fromCircle(center: leftEyeCenter, radius: eyeRadius);
    final rightEyeRect = Rect.fromCircle(center: rightEyeCenter, radius: eyeRadius);

    // Arc from π to 2π => upward arcs with round ends
    canvas.drawArc(leftEyeRect, math.pi, math.pi, false, strokePaint);
    canvas.drawArc(rightEyeRect, math.pi, math.pi, false, strokePaint);

    // Smiling mouth: upward arc with round edges
    final mouthRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.48),
      width: size.width * 0.30,
      height: size.height * 0.08,
    );
    canvas.drawArc(mouthRect, math.pi, -math.pi, false, strokePaint);
  }

  // ----------------------------------------------------------------
  // 4) HAPPY FACE
  // ----------------------------------------------------------------
  void _drawHappyFace(Canvas canvas, Size size) {
    // Big open eyes as circles (filled), plus a large round smile (stroked)
    final fillPaint = Paint()..color = Colors.black;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final eyeRadius = size.width * 0.03;
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.3), eyeRadius, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.3), eyeRadius, fillPaint);

    // Large smile: stroke arc with round edges
    final mouthRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.50),
      width: size.width * 0.40,
      height: size.height * 0.15,
    );
    // Arc from math.pi to 0 => large upward smile
    canvas.drawArc(mouthRect, math.pi, -math.pi, false, strokePaint);
  }

  @override
  bool shouldRepaint(covariant StreakFace oldDelegate) {
    return oldDelegate.color != color || oldDelegate.result != result;
  }
}

enum Expression {
  angry,
  sad,
  smiling,
  happy,
}
