import 'dart:collection';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

import '../models/BodyPart.dart';
import '../models/Exercise.dart';

class ExerciseProvider with ChangeNotifier {
  final List<Exercise> _exercises = [
    Exercise(id: "c4a3a703-e061-45af-8208-b15461c1d1ad", name: 'Incline Dumbbells', bodyPart: BodyPart.CHEST),
    Exercise(id: "cef553c5-be65-472b-94fb-80db4afe415", name: 'Chest Fly', bodyPart: BodyPart.CHEST),
    Exercise(id: "6e7bf40f-2c0b-43cd-9466-685f4a32156c", name: 'Decline Smith machine press', bodyPart: BodyPart.CHEST),
    Exercise(id: "d471bddd-1d41-4d72-887e-3d969905d45f", name: 'Chest Dips', bodyPart: BodyPart.CHEST),
    Exercise(id: "6f91bc0e-b18f-4260-8b39-a4801c6b208b", name: 'Lateral Raises', bodyPart: BodyPart.SHOULDERS),
    Exercise(id: "b58094f2-ca09-42c7-855e-5dd36d336a97", name: 'Military press', bodyPart: BodyPart.SHOULDERS),
    Exercise(id: "84144f20-49c9-49c6-8005-20a47f3b8245", name: 'Single Lateral Raises', bodyPart: BodyPart.SHOULDERS),
    Exercise(id: "85187a32-7d66-4851-8ca9-b3fa99a17cc4", name: 'Double Lateral Raises', bodyPart: BodyPart.SHOULDERS),
    Exercise(id: "85187a32-7d16-4851-8ca9-b3fag9a17cc4", name: 'Skull Crushers', bodyPart: BodyPart.TRICEPS),
    Exercise(id: "85187a32-7366-4851-8ca9-b3fas9a17cc4", name: 'Tricep Extensions', bodyPart: BodyPart.TRICEPS),
    Exercise(id: "85187a32-7866-4851-8ca9-b3fa99a17cc4", name: 'Tricep Dips', bodyPart: BodyPart.TRICEPS),
    Exercise(id: "85187a32-7d66-4851-8ca9-b3fad9a17c34", name: 'Pulldowns', bodyPart: BodyPart.TRICEPS),
    Exercise(id: "80187c32-7d66-4851-8ca9-b3fad9a17c34", name: 'Deadlift', bodyPart: BodyPart.LEGS),
    Exercise(id: "35187a32-7d66-4851-8ca9-b3f6d9a17c34", name: 'Hamstring Curls', bodyPart: BodyPart.LEGS),
    Exercise(id: "851z7a32-7dx6-4851-8ca9-b3fad9a17n34", name: 'Romanian Deadlift', bodyPart: BodyPart.LEGS),
    Exercise(id: "851x7a32-wd66-4v51-8ca9-b3cad9a17c34", name: 'Single Leg Curl', bodyPart: BodyPart.LEGS)
  ];

  UnmodifiableListView<Exercise> get exercises => UnmodifiableListView(_exercises);

  ExerciseProvider() {
    //_listExercises();
  }

  void _listExercises() async {
    final exercises = await Amplify.DataStore.query(Exercise.classType);
    _exercises.addAll(exercises);
    notifyListeners();
  }

  Future<void> saveExercise({required String id, required String name, required BodyPart bodyPart}) async {
    final exerciseToSave = Exercise(name: name, bodyPart: bodyPart);
    await Amplify.DataStore.save<Exercise>(exerciseToSave);
    _exercises.add(exerciseToSave);
    notifyListeners();
  }

  Exercise whereExercise({required String exerciseId}) {
    return _exercises.firstWhere((exercise) => exercise.id == exerciseId);
  }

  void _createTempExercises() async {
    await saveExercise(id: "c4a3a703-e061-45af-8208-b15461c1d1ad", name: 'Incline Dumbbells', bodyPart: BodyPart.CHEST);
    await saveExercise(id: "cef553c5-be65-472b-94fb-80db4afe415", name: 'Chest Fly', bodyPart: BodyPart.CHEST);
    await saveExercise(
        id: "6e7bf40f-2c0b-43cd-9466-685f4a32156c", name: 'Decline Smith machine press', bodyPart: BodyPart.CHEST);
    await saveExercise(id: "d471bddd-1d41-4d72-887e-3d969905d45f", name: 'Chest Dips', bodyPart: BodyPart.CHEST);

    await saveExercise(
        id: "6f91bc0e-b18f-4260-8b39-a4801c6b208b", name: 'Lateral Raises', bodyPart: BodyPart.SHOULDERS);
    await saveExercise(
        id: "b58094f2-ca09-42c7-855e-5dd36d336a97", name: 'Military press', bodyPart: BodyPart.SHOULDERS);
    await saveExercise(
        id: "84144f20-49c9-49c6-8005-20a47f3b8245", name: 'Single Lateral Raises', bodyPart: BodyPart.SHOULDERS);
    await saveExercise(
        id: "85187a32-7d66-4851-8ca9-b3fa99a17cc4", name: 'Double Lateral Raises', bodyPart: BodyPart.SHOULDERS);

    await saveExercise(id: "85187a32-7d16-4851-8ca9-b3fag9a17cc4", name: 'Skull Crushers', bodyPart: BodyPart.TRICEPS);
    await saveExercise(
        id: "85187a32-7366-4851-8ca9-b3fas9a17cc4", name: 'Tricep Extensions', bodyPart: BodyPart.TRICEPS);
    await saveExercise(id: "85187a32-7866-4851-8ca9-b3fa99a17cc4", name: 'Tricep Dips', bodyPart: BodyPart.TRICEPS);
    await saveExercise(id: "85187a32-7d66-4851-8ca9-b3fad9a17c34", name: 'Pulldowns', bodyPart: BodyPart.TRICEPS);

    await saveExercise(id: "80187c32-7d66-4851-8ca9-b3fad9a17c34", name: 'Deadlift', bodyPart: BodyPart.LEGS);
    await saveExercise(id: "35187a32-7d66-4851-8ca9-b3f6d9a17c34", name: 'Hamstring Curls', bodyPart: BodyPart.LEGS);
    await saveExercise(id: "851z7a32-7dx6-4851-8ca9-b3fad9a17n34", name: 'Romanian Deadlift', bodyPart: BodyPart.LEGS);
    await saveExercise(id: "851x7a32-wd66-4v51-8ca9-b3cad9a17c34", name: 'Single Leg Curl', bodyPart: BodyPart.LEGS);
  }
}
