import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/widgets/muscle_group/selectable_muscle_group_widget.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../widgets/buttons/text_button_widget.dart';

class MuscleGroupDto {
  final bool selected;
  final MuscleGroup muscleGroup;

  MuscleGroupDto({this.selected = false, required this.muscleGroup});

  MuscleGroupDto copyWith({bool? selected, MuscleGroup? muscleGroup}) {
    return MuscleGroupDto(
      selected: selected ?? this.selected,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }
}

class MuscleGroupsScreen extends StatefulWidget {
  final List<MuscleGroup>? muscleGroups;
  final bool multiSelect;

  const MuscleGroupsScreen({super.key, this.muscleGroups, this.multiSelect = true});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  List<MuscleGroupDto> _muscleGroups = [];

  List<MuscleGroupDto> _filteredMuscleGroups = [];

  /// Search through the list of exercises
  void _runSearch(String searchTerm) {
    setState(() {
      final query = searchTerm.toLowerCase();
      _filteredMuscleGroups = _muscleGroups
          .where((muscleGroup) => (muscleGroup.muscleGroup.name.toLowerCase().contains(query) ||
              muscleGroup.muscleGroup.name.toLowerCase().startsWith(query) ||
              muscleGroup.muscleGroup.name.toLowerCase().endsWith(query) ||
              muscleGroup.muscleGroup.name.toLowerCase() == query))
          .toList();
    });
  }

  /// Navigate to previous screen
  void _addSelectedMuscleGroup() {
    final muscleGroups = _whereSelectedMuscleGroups().map((muscle) => muscle.muscleGroup).toList();
    Navigator.of(context).pop(muscleGroups);
  }

  int _indexWhereMuscleGroup({required MuscleGroup muscleGroup}) {
    return _muscleGroups.indexWhere((exerciseInLibrary) => exerciseInLibrary.muscleGroup == muscleGroup);
  }

  List<MuscleGroupDto> _whereSelectedMuscleGroups() {
    return _muscleGroups.where((muscle) => muscle.selected).toList();
  }

  bool _hasChangesToMuscleGroups() {
    final previousMuscleGroups = widget.muscleGroups;

    if(previousMuscleGroups != null) {
      return _whereSelectedMuscleGroups().isEmpty;
    }
    return false;
  }

  /// Select up to many exercise
  void _selectCheckedMuscleGroup({required bool selected, required MuscleGroupDto muscleGroupDto}) {
    final muscleGroupIndex = _indexWhereMuscleGroup(muscleGroup: muscleGroupDto.muscleGroup);
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
    Navigator.of(context).pop([muscleGroupDto.muscleGroup]);
  }

  Widget _muscleGroupWidget(MuscleGroupDto muscleGroupDto) {
    if (widget.multiSelect) {
      return SelectableMuscleGroupWidget(
          muscleGroupDto: muscleGroupDto,
          onTap: (selected) => _selectCheckedMuscleGroup(selected: selected, muscleGroupDto: muscleGroupDto));
    }
    return SelectableMuscleGroupWidget(
        muscleGroupDto: muscleGroupDto, onTap: (_) => _selectMuscleGroup(muscleGroupDto: muscleGroupDto));
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
          if(_whereSelectedMuscleGroups().isNotEmpty)
            CTextButton(
              onPressed: _addSelectedMuscleGroup,
              label: "Add (${_whereSelectedMuscleGroups().length})",
              buttonColor: Colors.transparent,
            ),
          if(_hasChangesToMuscleGroups())
            CTextButton(
              onPressed: _addSelectedMuscleGroup,
              label: "Update",
              buttonColor: Colors.transparent,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
        child: Column(
          children: [
            CSearchBar(hintText: 'Search muscle groups', onChanged: _runSearch),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) => _muscleGroupWidget(_filteredMuscleGroups[index]),
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(color: Colors.white70.withOpacity(0.1)),
                  itemCount: _filteredMuscleGroups.length),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final muscleGroupsDtos = MuscleGroup.values.map((muscleGroup) => MuscleGroupDto(muscleGroup: muscleGroup)).toList();
    final previousMuscleGroups = widget.muscleGroups;
    if (previousMuscleGroups != null) {
      final previousMuscleGroupsDtos = previousMuscleGroups.map((muscleGroup) {
        return MuscleGroupDto(muscleGroup: muscleGroup, selected: true);
      }).toList();
      _muscleGroups = muscleGroupsDtos.map((muscleGroup) {
        final previousMuscleGroup = previousMuscleGroupsDtos.firstWhereOrNull(
            (previousMuscleGroup) => previousMuscleGroup.muscleGroup.name == muscleGroup.muscleGroup.name);
        return previousMuscleGroup ?? muscleGroup;
      }).toList();
    }

    _filteredMuscleGroups = _muscleGroups;
  }
}
