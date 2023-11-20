import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import '../../../dtos/set_dto.dart';

class SetCheckButton extends StatelessWidget {
  final SetDto setDto;
  final VoidCallback onCheck;

  const SetCheckButton({super.key, required this.setDto, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCheck,
      child: Icon(
        setDto.checked ? Icons.check_box_rounded : Icons.check_box_rounded,
        color:  setDto.checked ? Colors.green : tealBlueLighter,
      ),
    );
  }
}
