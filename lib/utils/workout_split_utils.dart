import '../enums/muscle_group_enums.dart';

/// The possible training splits we’re classifying for.
enum TrainingSplit {
  fullBody("Full body"),
  upperLower("Upper/Lower"),
  pushPullLegs("Push Pull Legs"),
  broSplit("Bro Split"),
  unknown("Unknown");

  const TrainingSplit(this.display);

  final String display;
}

// Constants for muscle group classifications
const upperBody = <MuscleGroup>{
  MuscleGroup.chest,
  MuscleGroup.back,
  MuscleGroup.shoulders,
  MuscleGroup.biceps,
  MuscleGroup.triceps,
  MuscleGroup.forearms,
  MuscleGroup.frontShoulder,
  MuscleGroup.backShoulder,
  MuscleGroup.lats,
  MuscleGroup.traps,
};

const lowerBody = <MuscleGroup>{
  MuscleGroup.quadriceps,
  MuscleGroup.hamstrings,
  MuscleGroup.adductors,
  MuscleGroup.abductors,
  MuscleGroup.glutes,
  MuscleGroup.calves,
};

const pushMuscles = <MuscleGroup>{
  MuscleGroup.chest,
  MuscleGroup.shoulders,
  MuscleGroup.triceps,
  MuscleGroup.frontShoulder,
  MuscleGroup.backShoulder,
};

const pullMuscles = <MuscleGroup>{
  MuscleGroup.back,
  MuscleGroup.lats,
  MuscleGroup.biceps,
  MuscleGroup.forearms,
  MuscleGroup.traps,
};

TrainingSplit determineTrainingSplit({required Set<MuscleGroup> muscleGroups}) {
  // 1. Single muscle group (Bro Split)
  if (muscleGroups.length == 1) {
    return TrainingSplit.broSplit;
  }

  // 2. Full-body check (contains both upper and lower body)
  final hasUpper = muscleGroups.intersection(upperBody).isNotEmpty;
  final hasLower = muscleGroups.intersection(lowerBody).isNotEmpty;
  if (hasUpper && hasLower) {
    return TrainingSplit.fullBody;
  }

  // 3. Push/Pull/Legs check (exclusive muscle group subsets)
  final isPush = pushMuscles.containsAll(muscleGroups);
  final isPull = pullMuscles.containsAll(muscleGroups);
  final isLegs = lowerBody.containsAll(muscleGroups);
  if (isPush || isPull || isLegs) {
    return TrainingSplit.pushPullLegs;
  }

  // 4. Upper/Lower check (remaining homogeneous workouts)
  final isUpperOnly = upperBody.containsAll(muscleGroups);
  final isLowerOnly = lowerBody.containsAll(muscleGroups);
  if (isUpperOnly || isLowerOnly) {
    return TrainingSplit.upperLower;
  }

  // No clear categorization
  return TrainingSplit.unknown;
}

String getTrainingSplitSummary({required TrainingSplit split}) {
  return switch(split) {

    TrainingSplit.fullBody => "You train all major muscle groups in a single workout. "
        "This approach maximizes frequency for each muscle group, "
        "suitable for beginners or those short on time.",

    TrainingSplit.upperLower => "You split your training into upper-body days and lower-body days. "
        "This split offers balanced volume and recovery across the week.",

    TrainingSplit.pushPullLegs => "You organize workouts into push (chest, shoulders, triceps), "
        "pull (back, biceps), and legs (quads, hamstrings, glutes). "
        "It’s a popular split for systematic training and recovery.",

    TrainingSplit.broSplit => "You focus on one primary muscle group each session (e.g., chest, back, arms). "
        "This classic approach allows high volume per muscle group but lower frequency.",

    TrainingSplit.unknown => "The training pattern doesn’t fit a well-defined split or more data is needed.",
  };

}