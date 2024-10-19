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
      ];
}

class MuscleGroup {
  final String name;
  final String description;
  final MuscleGroupFamily family;

  const MuscleGroup._(this.name, this.family, this.description);

  // Static constants representing individual muscle groups with family
  static const MuscleGroup forearms = MuscleGroup._("Forearms", MuscleGroupFamily.arms, "Forearms help with grip strength, wrist stability, and support for lifting and pulling movements.");
  static const MuscleGroup biceps = MuscleGroup._("Biceps", MuscleGroupFamily.arms, "Biceps are responsible for elbow flexion, assisting in pulling movements and lifting.");
  static const MuscleGroup triceps = MuscleGroup._("Triceps", MuscleGroupFamily.arms, "Triceps are the primary muscles for elbow extension, playing a key role in pushing movements.");
  static const MuscleGroup back = MuscleGroup._("Back", MuscleGroupFamily.back, "The back muscles support posture, pulling movements, and core stability.");
  static const MuscleGroup lats = MuscleGroup._("Lats", MuscleGroupFamily.back, "Latissimus dorsi muscles are crucial for pulling movements, such as pull-ups and rows, and contribute to a V-taper physique.");
  static const MuscleGroup traps = MuscleGroup._("Traps", MuscleGroupFamily.back, "Trapezius muscles stabilize the shoulder blades and assist in lifting, shrugging, and pulling movements.");
  static const MuscleGroup abs = MuscleGroup._("Abs", MuscleGroupFamily.core, "Abdominal muscles are essential for core stability, balance, and supporting almost all compound lifts.");
  static const MuscleGroup chest = MuscleGroup._("Chest", MuscleGroupFamily.chest, "The chest muscles are key for pushing movements, including presses and push-ups, and contribute to upper body strength.");
  static const MuscleGroup shoulders = MuscleGroup._("Shoulders", MuscleGroupFamily.shoulders, "Shoulders (deltoids) enable arm rotation and are involved in pushing and lifting movements.");
  static const MuscleGroup abductors = MuscleGroup._("Abductors", MuscleGroupFamily.legs, "Abductors are responsible for moving the legs away from the body's midline, essential for lateral movements.");
  static const MuscleGroup adductors = MuscleGroup._("Adductors", MuscleGroupFamily.legs, "Adductors bring the legs toward the midline of the body and support stability in squats and lunges.");
  static const MuscleGroup glutes = MuscleGroup._("Glutes", MuscleGroupFamily.legs, "Glutes are powerful muscles for hip extension, playing a key role in squats, deadlifts, and explosive movements.");
  static const MuscleGroup hamstrings = MuscleGroup._("Hamstrings", MuscleGroupFamily.legs, "Hamstrings are responsible for knee flexion and hip extension, aiding in running, jumping, and lower-body lifts.");
  static const MuscleGroup quadriceps = MuscleGroup._("Quadriceps", MuscleGroupFamily.legs, "Quadriceps are key for knee extension, vital for squats, lunges, and running.");
  static const MuscleGroup calves = MuscleGroup._("Calves", MuscleGroupFamily.legs, "Calves enable ankle flexion, essential for running, jumping, and stability in lower-body movements.");
  static const MuscleGroup neck = MuscleGroup._("Neck", MuscleGroupFamily.neck, "Neck muscles help stabilize the head and support posture.");
  static const MuscleGroup fullBody = MuscleGroup._("Full Body", MuscleGroupFamily.fullBody, "Full body exercises engage multiple muscle groups, improving overall strength and endurance.");
  static const MuscleGroup none = MuscleGroup._("None", MuscleGroupFamily.fullBody, "No specific muscle group targeted.");

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
