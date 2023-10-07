import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetListItemTextField extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;

  const SetListItemTextField(
      {super.key, required this.label, required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: CupertinoColors.opaqueSeparator),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: 30,
          child: CupertinoTextField(
            controller: textEditingController,
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.number,
            maxLength: 3,
            maxLines: 1,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: const TextStyle(fontWeight: FontWeight.bold),
            placeholder: "0",
            placeholderStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: CupertinoColors.white),
          ),
        )
      ],
    );
  }
}
