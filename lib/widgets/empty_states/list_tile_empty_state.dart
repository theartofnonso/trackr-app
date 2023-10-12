import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_constants.dart';

class ListStyleEmptyState extends StatelessWidget {
  const ListStyleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Container(
          width: 160,
          height: 10,
          decoration: BoxDecoration(
            color: tealBlueLighter,
            borderRadius:
                BorderRadius.circular(10.0), // Adjust the radius as needed
          )),
      leading: const CircleAvatar(
        backgroundColor: tealBlueLighter,
      ),
      subtitle: Container(
          width: 90,
          height: 10,
          decoration: BoxDecoration(
            color: tealBlueLighter,
            borderRadius:
                BorderRadius.circular(10.0), // Adjust the radius as needed
          )),
    );
  }
}
