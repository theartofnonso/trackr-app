import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/procedures_provider.dart';

class SetCheckButton extends StatelessWidget {
  final String exerciseId;
  final int setIndex;
  final void Function() onCheckSet;

  const SetCheckButton({
    super.key,
    required this.exerciseId,
    required this.setIndex,
    required this.onCheckSet,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
        //final set = procedureProvider.setWhereProcedure(exerciseId: exerciseId, setIndex: setIndex);
        bool checked = false;
        return GestureDetector(
          onTap: () {
            // Update the set's checked status in the provider
            procedureProvider.checkSet(exerciseId: exerciseId, setIndex: setIndex);
            // Update the local state to reflect the change
            setState(() {
              checked = !checked; // Toggle the checked state
            });
            onCheckSet(); // Call the callback function
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
