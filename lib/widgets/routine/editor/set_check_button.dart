import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import '../../../dtos/set_dto.dart';

class SetCheckButton extends StatefulWidget {
  final String procedureId;
  final int setIndex;
  final SetDto setDto;
  final VoidCallback onCheck;

  const SetCheckButton({
    Key? key,
    required this.procedureId,
    required this.setIndex,
    required this.setDto,
    required this.onCheck,
  }) : super(key: key);

  @override
  State<SetCheckButton> createState() => _SetCheckButtonState();
}

class _SetCheckButtonState extends State<SetCheckButton> {
  late bool checked;

  @override
  void initState() {
    super.initState();
    checked = widget.setDto.checked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          checked = !checked; // Toggle the checked state
        });
        // Call the callback function
        widget.onCheck();
      },
      child: Icon(
        checked ? Icons.check_box : Icons.check_box_rounded,
        color: checked ? Colors.green : tealBlueLighter,
      ),
    );
  }
}
