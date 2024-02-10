import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../widgets/muscle_group/muscle_group_widget.dart';

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

  @override
  String toString() {
    return 'MuscleGroupDto{selected: $selected, muscleGroup: $muscleGroup}';
  }
}

class MuscleGroupsScreen extends StatefulWidget {
  final MuscleGroup previousMuscleGroup;

  const MuscleGroupsScreen({super.key, required this.previousMuscleGroup});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  late TextEditingController _searchController;

  late List<MuscleGroupDto> _muscleGroups = [];

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

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredMuscleGroups = _muscleGroups;
    });
  }

  /// Select an muscle group
  void _selectMuscleGroup({required MuscleGroupDto muscleGroupDto}) {
    Navigator.of(context).pop(muscleGroupDto.muscleGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            children: [
              CSearchBar(
                  hintText: 'Search muscle groups',
                  onChanged: _runSearch,
                  onClear: _clearSearch,
                  controller: _searchController),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) => MuscleGroupWidget(
                        muscleGroupDto: _filteredMuscleGroups[index],
                        onTap: () => _selectMuscleGroup(muscleGroupDto: _filteredMuscleGroups[index])),
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(color: Colors.white70.withOpacity(0.1)),
                    itemCount: _filteredMuscleGroups.length),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    _muscleGroups = MuscleGroup.values
        .whereNot((muscleGroup) => muscleGroup == MuscleGroup.legs)
        .sorted((a, b) => a.name.compareTo(b.name))
        .map((muscleGroup) {
      return MuscleGroupDto(muscleGroup: muscleGroup, selected: widget.previousMuscleGroup == muscleGroup);
    }).toList();

    _filteredMuscleGroups = _muscleGroups;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
