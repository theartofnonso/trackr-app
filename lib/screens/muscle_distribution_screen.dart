import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/BodyPart.dart';

import '../app_constants.dart';
import '../providers/routine_log_provider.dart';

class MuscleDistributionScreen extends StatefulWidget {
  const MuscleDistributionScreen({super.key});

  @override
  State<MuscleDistributionScreen> createState() => _MuscleDistributionScreenState();
}

class _MuscleDistributionScreenState extends State<MuscleDistributionScreen> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  Widget build(BuildContext context) {

    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: _navigateBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            ..._bodyPartSplit(provider: routineLogProvider)
          ],),
        ),
      ),
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  Map<String, double> _calculateBodySplitPercentage ({required RoutineLogProvider provider}) {
    const bodyParts = BodyPart.values;

    final Map<BodyPart, int> frequencyMap = {};

    // Count the occurrences of each bodyPart
    for (BodyPart bodyPart in bodyParts) {
      frequencyMap[bodyPart] = provider.whereSetDtos(bodyPart: bodyPart, context: context).length;
    }

    final int totalItems = bodyParts.length;
    final Map<String, double> percentageMap = {};

    // Calculate the percentage for each bodyPart
    frequencyMap.forEach((item, count) {
      final double percentage = ((count / totalItems) * 100.0) / 100;
      percentageMap[item.name] = percentage;
    });

    return percentageMap;
  }

  List<Widget> _bodyPartSplit({required RoutineLogProvider provider}) {

    final splitMap = _calculateBodySplitPercentage(provider: provider);
    final splitList = <Widget>[];
    splitMap.forEach((key, value) {
      final widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$key ${(value * 100).toInt()}%",
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return LinearProgressIndicator(
                    value: value,
                    valueColor: _colorAnimation,
                    backgroundColor: tealBlueLight,
                    minHeight: 15,
                    borderRadius: BorderRadius.circular(2));
              }),
          const SizedBox(height: 12)
        ],
      );
      splitList.add(widget);
    });
    return splitList;
  }

  @override
  void initState() {
    super.initState();
    // Create an animation controller with a duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Create a tween for the color animation
    _colorAnimation = ColorTween(
      begin: tealBlueLight,
      end: Colors.blueAccent,
    ).animate(_controller);

    // Start the animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
