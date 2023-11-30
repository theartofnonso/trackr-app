import 'package:flutter/material.dart';

import '../../app_constants.dart';

class ListTileEmptyState extends StatelessWidget {
  const ListTileEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
         Container(
          width: 30,
          height: 30,
           decoration: BoxDecoration(
             color: tealBlueLighter, // Container color
             borderRadius: BorderRadius.circular(5), // Border radius
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
        const Spacer(),
        Container(
            width: 30,
            height: 10,
            decoration: BoxDecoration(
              color: tealBlueLighter,
              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
            ))
      ],
    );
  }
}
