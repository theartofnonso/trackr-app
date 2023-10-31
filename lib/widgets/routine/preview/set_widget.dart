import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';

import '../../../app_constants.dart';
import '../../../providers/weight_unit_provider.dart';
import '../../../utils/general_utils.dart';

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
    final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
    final value = weightProvider.isLbs ? toLbs(setDto.weight) : setDto.weight;

    return ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        tileColor: tealBlueLight,
        leading: _SetIcon(type: setDto.type, label: workingIndex),
        title: Row(children: [
          RepText(label: "REPS", value: setDto.reps),
          const SizedBox(width: 10),
          WeightText(label: weightLabel().toUpperCase(), value: value)
        ], ));
  }
}

class RepText extends StatelessWidget {

  final String label;
  final int value;

  const RepText({super.key, required this.label, required this.value});

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

class WeightText extends StatelessWidget {

  final String label;
  final double value;

  const WeightText({super.key, required this.label, required this.value});

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
