import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/set_dto.dart';

import '../../../app_constants.dart';

class SetWidget extends StatelessWidget {
  const SetWidget({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.setDto,
  });

  final int index;
  final int workingIndex;
  final SetDto setDto;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        tileColor: tealBlueLight,
        leading: _SetIcon(type: setDto.type, label: workingIndex),
        title: Row(children: [
          SetText(label: "REPS", value: setDto.rep),
          const SizedBox(width: 10),
          SetText(label: "KG", value: setDto.weight)
        ],));
  }
}

class SetText extends StatelessWidget {

  final String label;
  final int value;

  const SetText({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 10),
        Text("$value", style: const TextStyle(color: Colors.white),)
      ],),
    );
  }
}


class _SetIcon extends StatelessWidget {
  const _SetIcon({
    required this.type,
    required this.label,
  });

  final SetType type;
  final int label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Text(
        type == SetType.working ? "${label + 1}" : type.label,
        style: TextStyle(color: type.color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
