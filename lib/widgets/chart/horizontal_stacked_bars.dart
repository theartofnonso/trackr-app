import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

class HorizontalStackedBars extends StatelessWidget {
  final List<int> weights;
  final List<Color> colors;

  const HorizontalStackedBars(
      {super.key, required this.weights, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Define the weights and colors for the bars
    final List<_Bar> bars = weights
        .mapIndexed((index, value) => _Bar(weight: value, color: colors[index]))
        .toList();
    // Create a list of Expanded widgets based on the weights
    final List<Widget> weightedBars = bars.map((bar) {
      return Expanded(
        flex: (bar.weight), // Calculate the flex factor based on the weight
        child: Container(
          height: 10, // Fixed height for all bars
          color: bar.color,
        ),
      );
    }).toList();

    return Row(
      children: weightedBars,
    );
  }
}

// A simple class to hold the weight and color for a bar
class _Bar {
  final int weight;
  final Color color;

  _Bar({required this.weight, required this.color});
}
