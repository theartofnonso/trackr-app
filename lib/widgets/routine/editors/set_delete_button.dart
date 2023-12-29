import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SetDeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const SetDeleteButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: FaIcon(FontAwesomeIcons.solidRectangleXmark, color: Colors.red.withOpacity(0.9), size: 28),
    );
  }
}
