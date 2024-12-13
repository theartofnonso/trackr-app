import 'package:flutter/material.dart';

class OutlineListTile extends StatelessWidget {
  final String title;
  final String? trailing;
  final void Function() onTap;

  const OutlineListTile({super.key, required this.onTap, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;

    return ListTile(onTap: onTap, title: Text(title), trailing: trailing != null ? Text(trailing) : null);
  }
}
