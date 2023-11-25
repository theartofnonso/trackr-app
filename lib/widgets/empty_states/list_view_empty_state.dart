import 'package:flutter/material.dart';

import 'list_tile_empty_state.dart';

class ListViewEmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const ListViewEmptyState({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 150),
            itemBuilder: (BuildContext context, int index) => const ListTileEmptyState(),
            separatorBuilder: (BuildContext context, int index) =>
                Divider(color: Colors.white70.withOpacity(0.1)),
            itemCount: 3),
      ),
    );
  }
}
