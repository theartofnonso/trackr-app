import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';

class SetListEmptyState extends StatelessWidget {
  const SetListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color baseContainerColor =
        isDarkMode ? darkSurfaceContainer : Colors.grey.shade200;
    final Color baseLineColor =
        isDarkMode ? darkOnSurfaceSecondary : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          _placeholderRow(
            containerColor: baseContainerColor.withValues(alpha: 0.6),
            lineColor: baseLineColor.withValues(alpha: 0.25),
          ),
          _placeholderRow(
            containerColor: baseContainerColor.withValues(alpha: 0.5),
            lineColor: baseLineColor.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _placeholderRow(
      {required Color containerColor, required Color lineColor}) {
    return Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(radiusMD),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Table(
        columnWidths: const {
          1: FixedColumnWidth(50),
          2: FixedColumnWidth(50),
        },
        children: [
          TableRow(
            children: [
              Container(
                height: 10,
                width: 50,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                height: 10,
                width: 50,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
