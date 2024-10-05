class MuscleGroupFamily {
  final String name;

  const MuscleGroupFamily._(this.name);

  // Static constants representing different muscle group families
  static const MuscleGroupFamily legs = MuscleGroupFamily._("Legs");
  static const MuscleGroupFamily back = MuscleGroupFamily._("Back");
  static const MuscleGroupFamily arms = MuscleGroupFamily._("Arms");
  static const MuscleGroupFamily chest = MuscleGroupFamily._("Chest");
  static const MuscleGroupFamily shoulders = MuscleGroupFamily._("Shoulders");
  static const MuscleGroupFamily core = MuscleGroupFamily._("Core");
  static const MuscleGroupFamily neck = MuscleGroupFamily._("Neck");
  static const MuscleGroupFamily fullBody = MuscleGroupFamily._("Full Body");
  static const MuscleGroupFamily cardio = MuscleGroupFamily._("Cardio");
  static const MuscleGroupFamily none = MuscleGroupFamily._("None");

  // List of all families
  static List<MuscleGroupFamily> get values => [
        legs,
        back,
        arms,
        chest,
        shoulders,
        core,
        neck,
        fullBody,
        cardio,
      ];
}

class MuscleGroup {
  final String name;
  final MuscleGroupFamily family;

  const MuscleGroup._(this.name, this.family);

  // Static constants representing individual muscle groups with family
  static const MuscleGroup forearms = MuscleGroup._("Forearms", MuscleGroupFamily.arms);
  static const MuscleGroup biceps = MuscleGroup._("Biceps", MuscleGroupFamily.arms);
  static const MuscleGroup triceps = MuscleGroup._("Triceps", MuscleGroupFamily.arms);
  static const MuscleGroup back = MuscleGroup._("Back", MuscleGroupFamily.back);
  static const MuscleGroup lats = MuscleGroup._("Lats", MuscleGroupFamily.back);
  static const MuscleGroup traps = MuscleGroup._("Traps", MuscleGroupFamily.back);
  static const MuscleGroup abs = MuscleGroup._("Abs", MuscleGroupFamily.core);
  static const MuscleGroup chest = MuscleGroup._("Chest", MuscleGroupFamily.chest);
  static const MuscleGroup shoulders = MuscleGroup._("Shoulders", MuscleGroupFamily.shoulders);
  static const MuscleGroup abductors = MuscleGroup._("Abductors", MuscleGroupFamily.legs);
  static const MuscleGroup adductors = MuscleGroup._("Adductors", MuscleGroupFamily.legs);
  static const MuscleGroup glutes = MuscleGroup._("Glutes", MuscleGroupFamily.legs);
  static const MuscleGroup hamstrings = MuscleGroup._("Hamstrings", MuscleGroupFamily.legs);
  static const MuscleGroup quadriceps = MuscleGroup._("Quadriceps", MuscleGroupFamily.legs);
  static const MuscleGroup calves = MuscleGroup._("Calves", MuscleGroupFamily.legs);
  static const MuscleGroup neck = MuscleGroup._("Neck", MuscleGroupFamily.neck);
  static const MuscleGroup cardio = MuscleGroup._("Cardio", MuscleGroupFamily.cardio);
  static const MuscleGroup fullBody = MuscleGroup._("Full Body", MuscleGroupFamily.fullBody);
  static const MuscleGroup none = MuscleGroup._("None", MuscleGroupFamily.fullBody);

  // List of all muscle groups
  static List<MuscleGroup> get values => [
        forearms,
        biceps,
        triceps,
        lats,
        traps,
        back,
        abs,
        chest,
        shoulders,
        abductors,
        adductors,
        glutes,
        hamstrings,
        quadriceps,
        calves,
        neck,
        cardio,
        fullBody,
      ];

  // Get all muscle groups by a specific family
  static List<MuscleGroup> byFamily(MuscleGroupFamily family) {
    return values.where((group) => group.family == family).toList();
  }

  // Find a MuscleGroup by its name (case insensitive)
  static MuscleGroup fromString(String string) {
    return MuscleGroup.values.firstWhere(
      (group) => group.name.toLowerCase() == string.toLowerCase(),
      orElse: () => MuscleGroup.none,
    );
  }
}
