import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          onPressed: () => Navigator.of(context).pop(),
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
                      title: Text(exerciseTypes[index].name, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(exerciseTypes[index].description,
                          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 13)),
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
    };

    final itemWidgets = measurements
        .map((measurement) => Text(measurement, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white70)))
        .toList();

    return SizedBox(
      width: 70,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: itemWidgets),
    );
  }
}
