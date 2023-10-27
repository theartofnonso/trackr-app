import 'package:flutter/material.dart';

import '../../app_constants.dart';

class ListStyleEmptyState extends StatelessWidget {
  const ListStyleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 30,
          height: 30,
          child: CircleAvatar(
            backgroundColor: tealBlueLighter,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 160,
                height: 10,
                decoration: BoxDecoration(
                  color: tealBlueLighter,
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                )),
            const SizedBox(height: 5),
            Container(
                width: 100,
                height: 10,
                decoration: BoxDecoration(
                  color: tealBlueLighter,
                  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                ))
          ],
        ),
      ],
    );
  }
}
