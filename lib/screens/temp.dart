import 'package:flutter/material.dart';

import '../app_constants.dart';

class MonthGrid extends StatelessWidget {

  const MonthGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // The number of containers per row is 3.
    int containersPerRow = 3;

    // Get the screen width.
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the width of each container. Here, we subtract the padding (16.0 on each side) and
    // the spacing between the containers (8.0 between each container, hence 16.0 total for two gaps).
    double containerWidth = (screenWidth - (16.0 * 2) - (16.0 * (containersPerRow - 1))) / containersPerRow;

    // The aspect ratio for the GridView based on the container width and the screen height.
    double aspectRatio = containerWidth / (screenWidth / 3);

    return GridView.count(
      crossAxisCount: containersPerRow,
      childAspectRatio: aspectRatio,
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
      children: List.generate(12, (index) {
        // Generate 12 containers for each month.
        return _buildMonthContainer();
      }),
    );
  }

  Widget _buildMonthContainer() {

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1, // for square shape
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: 35, // Just an example to vary the number of squares
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: index.isEven ? vibrantGreen : Colors.transparent, // Alternate colors for demonstration
            border: Border.all(color: vibrantGreen, width: 1.0),
          ),
        );
      },
    );
  }
}