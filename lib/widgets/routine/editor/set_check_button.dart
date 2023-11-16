import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../dtos/set_dto.dart';
import '../../../providers/procedures_provider.dart';

class SetCheckButton extends StatelessWidget {
  final String procedureId;
  final int setIndex;
  final SetDto setDto;
  final VoidCallback onCheck;

  const SetCheckButton({
    super.key,
    required this.procedureId,
    required this.setIndex, required this.setDto, required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
        bool checked = setDto.checked;
        return GestureDetector(
          onTap: () {
            // Update the set's checked status in the provider
            procedureProvider.checkSet(procedureId: procedureId, setIndex: setIndex, setDto: setDto.copyWith(checked: !checked));
            // Update the local state to reflect the change
            setState(() {
              checked = !checked; // Toggle the checked state
            });// Call the callback function
            onCheck();
          },
          child: Icon(
            checked ? Icons.check_box_rounded : Icons.check_box_rounded,
            color: checked ? Colors.green : Colors.grey,
          ),
        );
      },
    );
  }
}
