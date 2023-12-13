import 'package:flutter/material.dart';

import 'list_tile_empty_state.dart';

class ListViewEmptyState extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  const ListViewEmptyState({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () => Future(() => null),
      child: const Column(children: [
        ListTileEmptyState(),
        SizedBox(height: 8),
        ListTileEmptyState(),
      ]),
    );
  }
}
