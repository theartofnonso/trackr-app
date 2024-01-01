import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      clipBehavior: Clip.antiAlias,
      color: tealBlueLighter,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: tealBlueLighter,
      ),
    );
  }
}

