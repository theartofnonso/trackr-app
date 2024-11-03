import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/exercise_type_enums.dart';

class ExerciseTypeScreen extends StatefulWidget {
  const ExerciseTypeScreen({super.key});

  @override
  State<ExerciseTypeScreen> createState() => _ExerciseTypeScreenState();
}

class _ExerciseTypeScreenState extends State<ExerciseTypeScreen> {
  /// Select an muscle group
  void _selectExerciseType({required ExerciseType type}) {
    Navigator.of(context).pop(type);
  }

  @override
  Widget build(BuildContext context) {
    const exerciseTypes = ExerciseType.values;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        width: double.infinity,
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
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) => ListTile(
                      onTap: () => _selectExerciseType(type: exerciseTypes[index]),
                      trailing: _TrailingWidget(type: exerciseTypes[index]),
                      title: Text(exerciseTypes[index].name, style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(exerciseTypes[index].description,
                          style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 13)),
                      dense: true),
                  separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
                  itemCount: exerciseTypes.length),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailingWidget extends StatelessWidget {
  final ExerciseType type;

  const _TrailingWidget({required this.type});

  @override
  Widget build(BuildContext context) {
    List<String> measurements = switch (type) {
      ExerciseType.weights => ["KG", " | ", "REPS"],
      ExerciseType.bodyWeight => ["REPS"],
      ExerciseType.duration => ["TIME"],
      ExerciseType.none => throw Exception("Exercise type does not exist"),
    };

    final itemWidgets = measurements
        .map((measurement) => Text(measurement, style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white70)))
        .toList();

    return SizedBox(
      width: 70,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: itemWidgets),
    );
  }
}
