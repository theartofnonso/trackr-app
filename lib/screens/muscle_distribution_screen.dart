import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/BodyPart.dart';
import 'package:tracker_app/widgets/chart/pie_chart_widget.dart';

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

    final splitMapEntries = _calculateBodySplitPercentage(provider: routineLogProvider);

    final splitMap = Map.fromEntries(splitMapEntries);

    final bodySplit = _bodyPartSplit(splitMap);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
        title: const Text("Muscle Distribution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: _navigateBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PieChartWidget(segments: splitMapEntries.take(3).toList()),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) => bodySplit[index],
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(),
                    itemCount: bodySplit.length),
              )
              //..._bodyPartSplit(provider: routineLogProvider)],
            ]),
      ),
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  List<MapEntry<String, int>> _calculateBodySplitPercentage({required RoutineLogProvider provider}) {
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

    return percentageMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value));

  }

  List<Widget> _bodyPartSplit(Map<String, int> splitMap) {
    final splitList = <Widget>[];
    splitMap.forEach((key, value) {
      final widget = Padding(
        key: Key(key),
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          tileColor: tealBlueLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3.0), // Adjust the border radius as needed
            ),
            title: Text(key, style: Theme.of(context).textTheme.labelLarge),
            trailing: Text("$value", style: Theme.of(context).textTheme.labelLarge)),
      );
      splitList.add(widget);
    });
    return splitList;
  }
}
