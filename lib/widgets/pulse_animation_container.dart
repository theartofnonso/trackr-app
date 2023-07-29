import 'dart:async';

import 'package:flutter/material.dart';

class PulsatingWidget extends StatefulWidget {

  final Widget child;

  const PulsatingWidget({Key? key, required this.child,}) : super(key: key);

  @override
  State<PulsatingWidget> createState() => _PulsatingWidgetState();
}

class _PulsatingWidgetState extends State<PulsatingWidget> {

  double _opacityLevel = 1.0;

  Timer? _timer;

  void _changeOpacity() {
    setState(() => _opacityLevel = _opacityLevel == 0.4 ? 1.0 : 0.4);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _changeOpacity());
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacityLevel,
      duration: const Duration(seconds: 1),
      child: widget.child,
    );
  }
}
