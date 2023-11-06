import 'package:flutter/material.dart';
import 'package:tracker_app/models/BodyPart.dart';
import 'package:tracker_app/widgets/exercise/muscle_group_widget.dart';
import 'package:tracker_app/widgets/exercise/selectable_muscle_group_widget.dart';

import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/exercise/selectable_exercise_widget.dart';

class MuscleGroupDto {
  final bool selected;
  final BodyPart bodyPart;

  MuscleGroupDto({this.selected = false, required this.bodyPart});

  MuscleGroupDto copyWith({bool? selected, BodyPart? exercise}) {
    return MuscleGroupDto(
      selected: selected ?? this.selected,
      bodyPart: exercise ?? this.bodyPart,
    );
  }
}

class MuscleGroupsScreen extends StatefulWidget {
  final bool multiSelect;

  const MuscleGroupsScreen({super.key, this.multiSelect = true});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  List<MuscleGroupDto> _muscleGroups = [];

  /// Navigate to previous screen
  void _addSelectedMuscleGroup() {
    final muscleGroups = _whereSelectedMuscleGroups().map((muscle) => muscle.bodyPart).toList();
    Navigator.of(context).pop(muscleGroups);
  }

  int _indexWhereMuscleGroup({required BodyPart bodyPart}) {
    return _muscleGroups.indexWhere((exerciseInLibrary) => exerciseInLibrary.bodyPart == bodyPart);
  }
  
  List<MuscleGroupDto> _whereSelectedMuscleGroups() {
    return _muscleGroups.where((muscle) => muscle.selected).toList();
  }

  /// Select up to many exercise
  void _selectCheckedMuscleGroup({required bool selected, required MuscleGroupDto muscleGroupDto}) {
    final muscleGroupIndex = _indexWhereMuscleGroup(bodyPart: muscleGroupDto.bodyPart);
    if (selected) {
      setState(() {
        _muscleGroups[muscleGroupIndex] = muscleGroupDto.copyWith(selected: true);
      });
    } else {
      setState(() {
        _muscleGroups[muscleGroupIndex] = muscleGroupDto.copyWith(selected: false);
      });
    }
  }

  /// Select an muscle group
  void _selectMuscleGroup({required MuscleGroupDto muscleGroupDto}) {
    Navigator.of(context).pop([muscleGroupDto.bodyPart]);
  }

  /// Convert [MuscleGroupDto] to [SelectableExerciseWidget]
  Widget _muscleGroupsToWidgets() {
    if (widget.multiSelect) {
      return ListView.separated(
          itemBuilder: (BuildContext context, int index) => SelectableMuscleGroupWidget(
              muscleGroupDto: _muscleGroups[index],
              onTap: (selected) => _selectCheckedMuscleGroup(selected: selected, muscleGroupDto: _muscleGroups[index])),
          separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
          itemCount: _muscleGroups.length);
    }
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => MuscleWidget(
            muscleGroupDto: _muscleGroups[index],
            onTap: () => _selectMuscleGroup(muscleGroupDto: _muscleGroups[index])),
        separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
        itemCount: _muscleGroups.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _whereSelectedMuscleGroups().isNotEmpty
              ? CTextButton(
                  onPressed: _addSelectedMuscleGroup,
                  label: "Add (${_whereSelectedMuscleGroups().length})",
                  buttonColor: Colors.transparent,
                )
              : const SizedBox.shrink()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
        child: Column(
          children: [
            Expanded(child: _muscleGroupsToWidgets())
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _muscleGroups = BodyPart.values.map((bodyPart) => MuscleGroupDto(bodyPart: bodyPart)).toList();
  }
}
