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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            ..._bodyPartSplit(provider: routineLogProvider)
          ],),
        ),
      ),
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  Map<String, int> _calculateBodySplitPercentage ({required RoutineLogProvider provider}) {
    const bodyParts = BodyPart.values;

    final Map<BodyPart, int> frequencyMap = {};

    // Count the occurrences of each bodyPart
    for (BodyPart bodyPart in bodyParts) {
      frequencyMap[bodyPart] = provider.whereSetDtos(bodyPart: bodyPart, context: context).length;
    }

    final Map<String, int> percentageMap = {};

    // Calculate the percentage for each bodyPart
    frequencyMap.forEach((item, count) {
      percentageMap[item.name] = count;
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
            "$key $value",
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 12)
        ],
      );
      splitList.add(widget);
    });
    return splitList;
  }
}
