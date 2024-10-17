import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

class HorizontalStackedBars extends StatelessWidget {
  final List<int> weights;
  final List<Color> colors;

  const HorizontalStackedBars({super.key, required this.weights, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Define the weights and colors for the bars
    final List<_Bar> bars = weights.mapIndexed((index, value) => _Bar(weight: value, color: colors[index])).toList();

    // Calculate the total weight
    final int totalWeight = bars.fold(0, (previousValue, bar) => previousValue + bar.weight);

    // Create a list of Expanded widgets based on the weights
    final List<Widget> weightedBars = bars.map((bar) {
      return Expanded(
        flex: (_barWeight((bar.weight * 10) ~/ totalWeight)), // Calculate the flex factor based on the weight
        child: Container(
          height: 10, // Fixed height for all bars
          color: bar.color,
        ),
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Row(
        children: weightedBars,
      ),
    );
  }
}

int _barWeight(int value) {
  return value < 1 ? 1 : value;
}

// A simple class to hold the weight and color for a bar
class _Bar {
  final int weight;
  final Color color;

  _Bar({required this.weight, required this.color});
}
