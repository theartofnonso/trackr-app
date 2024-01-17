import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_one.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_two.dart';

import '../../dtos/routine_log_dto.dart';
import '../../enums/muscle_group_enums.dart';

class RoutineLogShareableContainer extends StatefulWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;

  const RoutineLogShareableContainer({super.key, required this.log, required this.frequencyData});

  @override
  State<RoutineLogShareableContainer> createState() => _RoutineLogShareableContainerState();
}

class _RoutineLogShareableContainerState extends State<RoutineLogShareableContainer> {

  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    final pages = [
      RoutineLogShareableOne(log: widget.log, frequencyData: widget.frequencyData),
      RoutineLogShareableTwo(log: widget.log, frequencyData: widget.frequencyData)
    ];

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      radius: const Radius.circular(3),
      thickness: 5,
      child: SingleChildScrollView(
        controller: _scrollController,
          scrollDirection: Axis.horizontal, child: Row(children: pages)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
}
