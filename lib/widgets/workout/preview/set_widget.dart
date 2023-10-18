import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/set_dto.dart';

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
    return CupertinoListTile(
        padding: EdgeInsets.zero,
        leading: _SetIcon(type: setDto.type, label: workingIndex),
        title: Text(
          "${setDto.rep} Reps - ${setDto.weight}kg",
          style: Theme.of(context).textTheme.bodyMedium,
        ));
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
      backgroundColor: type.color,
      child: Text(
        type == SetType.working ? "${label + 1}" : type.label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
