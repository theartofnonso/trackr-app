import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/list_view_empty_state.dart';

import '../../utils/navigation_utils.dart';
import '../dtos/routine_log_dto.dart';
import '../widgets/c_list_title.dart';

class RoutineLogsScreen extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const RoutineLogsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: Navigator.of(context).pop),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children: [
              logs.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 150),
                          itemBuilder: (BuildContext context, int index) => _RoutineLogWidget(log: logs[index]),
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.white70.withOpacity(0.1)),
                          itemCount: logs.length),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ListViewEmptyState(),
                        const SizedBox(height: 8),
                        Text("You have no logs",
                            style: GoogleFonts.lato(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white70))
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLogDto log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    return CListTile(
        title: log.name,
        subtitle: "${log.exerciseLogs.length} exercise(s)",
        trailing: log.createdAt.durationSinceOrDate(),
        onTap: () => navigateToRoutineLogPreview(context: context, log: log));
  }
}
