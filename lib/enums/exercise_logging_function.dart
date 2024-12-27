enum ExerciseLoggingFunction {
  addSet, removeSet, updateSet;

  static ExerciseLoggingFunction fromString(String string) {
    return ExerciseLoggingFunction.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}