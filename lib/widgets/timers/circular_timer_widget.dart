import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

class CircularTimerWidget extends StatefulWidget {
  /// If provided => countdown. If null => stopwatch (count-up).
  final Duration? initialDuration;
  final void Function(Duration duration)? onDurationChanged;
  final void Function(Duration duration)? onTimerComplete;

  const CircularTimerWidget({
    super.key,
    this.initialDuration,
    this.onDurationChanged,
    this.onTimerComplete,
  });

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _progressController; // for determinate ring
  late final AnimationController _spinController; // for indeterminate spinner

  Timer? _timer;

  Duration _elapsed = Duration.zero;
  Duration _total = Duration.zero;

  bool _isRunning = false;
  bool _isPaused = false;
  DateTime? _startTime;

  bool get _isCountdown => _total.inSeconds > 0;
  bool get _showSpinner => !_isCountdown && _isRunning;

  @override
  void initState() {
    super.initState();

    _total = widget.initialDuration ?? Duration.zero; // 0 => stopwatch
    _elapsed = Duration.zero;

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
    );

    _spinController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    // We don't need setState on every tick because we use AnimatedBuilder.
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _startTime = DateTime.now().subtract(_elapsed);
    });
    if (_showSpinner) _spinController.repeat();
    _startTick();
  }

  void _pauseTimer() {
    if (!_isRunning || _isPaused) return;
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
    if (_showSpinner) _spinController.stop();
  }

  void _resumeTimer() {
    if (!_isRunning || !_isPaused) return;
    setState(() {
      _isPaused = false;
      _startTime = DateTime.now().subtract(_elapsed);
    });
    if (_showSpinner) _spinController.repeat();
    _startTick();
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    _timer?.cancel();
    _timer = null;
    _spinController.stop();
  }

  void _addTime() {
    // Only meaningful in countdown mode
    if (!_isCountdown) return;
    setState(() {
      _total = _total + const Duration(minutes: 1);
      _recomputeProgress();
    });
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startTime == null) return;

      final now = DateTime.now();
      final newElapsed = now.difference(_startTime!);

      if (_isCountdown && newElapsed >= _total) {
        setState(() {
          _elapsed = _total;
          _recomputeProgress();
        });
        widget.onDurationChanged?.call(_elapsed);
        widget.onTimerComplete?.call(_elapsed);
        _stopTimer();
        return;
      }

      setState(() {
        _elapsed = newElapsed;
        _recomputeProgress();
      });

      widget.onDurationChanged?.call(_elapsed);
    });
  }

  void _recomputeProgress() {
    final totalSecs = _total.inSeconds;
    final elapsedSecs = _elapsed.inSeconds;
    double p = 0.0;

    if (totalSecs > 0) {
      p = elapsedSecs / totalSecs;
    } else {
      p = 0.0; // stopwatch: determinate ring off; spinner handles UI
    }
    _progressController.value = p.clamp(0.0, 1.0);
  }

  void _logDuration() {
    widget.onTimerComplete?.call(_elapsed);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Duration displayTime = _isCountdown
        ? (_total - _elapsed).clamp(Duration.zero, _total)
        : _elapsed;
    final String centerLabel = _isCountdown ? 'TIME LEFT' : 'TIME ELAPSED';

    // One AnimatedBuilder drives both determinate progress and spinner rotation.
    final listenable = Listenable.merge([_progressController, _spinController]);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
              : [const Color(0xFFF0F4F8), const Color(0xFFE2E8F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: listenable,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: CircularProgressPainter(
                        isDarkMode: isDarkMode,
                        // determinate inputs:
                        progress: _progressController.value,
                        // indeterminate inputs:
                        indeterminate: !_isCountdown,
                        spinT: _spinController.value, // 0..1 → angle
                        showSpinner: _showSpinner,
                      ),
                    );
                  },
                ),

                // Inner circle with time display
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFF4A4A4A),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayTime.hmsDigital(),
                        style: GoogleFonts.ubuntu(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        centerLabel,
                        style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isRunning)
                GestureDetector(
                  onTap: _startTimer,
                  child: _squareBtn(
                    child: const FaIcon(FontAwesomeIcons.play,
                        color: Colors.black, size: 18),
                  ),
                ),
              if (_isRunning)
                GestureDetector(
                  onTap: _isPaused ? _resumeTimer : _pauseTimer,
                  child: _squareBtn(
                    child: FaIcon(
                      _isPaused
                          ? FontAwesomeIcons.play
                          : FontAwesomeIcons.pause,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              if (_isRunning)
                GestureDetector(
                  onTap: _stopTimer,
                  child: _squareBtn(
                    dark: true,
                    child: const FaIcon(FontAwesomeIcons.stop,
                        color: Colors.white, size: 18),
                  ),
                ),
              // Only show +1 minute in countdown mode
              if (_isCountdown)
                GestureDetector(
                  onTap: _addTime,
                  child: _squareBtn(
                    child: const FaIcon(FontAwesomeIcons.plus,
                        color: Colors.black, size: 18),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Log Duration
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _elapsed > Duration.zero ? _logDuration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: vibrantGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 2,
              ),
              child: Text(
                'Log Duration',
                style: GoogleFonts.ubuntu(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _squareBtn({required Widget child, bool dark = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: dark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.20 : 0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  /// Determinate
  final double progress; // 0..1
  /// Indeterminate flags
  final bool indeterminate;
  final double spinT; // 0..1 → 0..2π
  final bool showSpinner;

  final bool isDarkMode;

  CircularProgressPainter({
    required this.progress,
    required this.indeterminate,
    required this.spinT,
    required this.showSpinner,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // --- Indeterminate spinner (stopwatch mode) ---
    if (indeterminate && showSpinner) {
      final startAngle = -math.pi / 2 + (2 * math.pi * spinT);
      final sweepAngle = 2 * math.pi * 0.30; // ~108° arc
      final spinnerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        spinnerPaint,
      );
      return; // don’t draw determinate elements
    }

    // --- Determinate progress (countdown mode) ---
    final p = progress.clamp(0.0, 1.0);
    if (p > 0) {
      final progressPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * p;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Progress handle
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final handleAngle = -math.pi / 2 + sweepAngle;
      final handleX = center.dx + radius * math.cos(handleAngle);
      final handleY = center.dy + radius * math.sin(handleAngle);
      canvas.drawCircle(Offset(handleX, handleY), 6, handlePaint);
    }

    // Minute markers
    final markerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * math.pi / 180 - math.pi / 2;
      final markerRadius = i % 5 == 0 ? radius - 15 : radius - 12;
      final markerX = center.dx + markerRadius * math.cos(angle);
      final markerY = center.dy + markerRadius * math.sin(angle);
      canvas.drawCircle(
          Offset(markerX, markerY), i % 5 == 0 ? 2 : 1, markerPaint);
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter old) {
    return old.progress != progress ||
        old.indeterminate != indeterminate ||
        old.spinT != spinT ||
        old.showSpinner != showSpinner ||
        old.isDarkMode != isDarkMode;
  }
}

extension on Duration {
  /// Clamp Duration into [min, max]; if max < min just returns this.
  Duration clamp(Duration min, Duration max) {
    if (max < min) return this;
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}
