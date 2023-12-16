import 'package:flutter/material.dart';

class SetDeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const SetDeleteButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: Icon(Icons.delete_outline_rounded, color: Colors.red.withOpacity(0.7), size: 25),
    );
  }
}
