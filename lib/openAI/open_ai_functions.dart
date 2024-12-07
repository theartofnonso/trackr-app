import '../enums/exercise_logging_function.dart';

const listExercisesFunctionTool = {
  "name": "list_exercises",
  "description":
      "Call this whenever you need to select exercises or make decisions involving exercises, please refer to the provided exercise data. Use this data to inform your choices and ensure accurate and relevant exercise recommendations",
};

final addSetFunctionTool = {
  "name": ExerciseLoggingFunction.addSet.name,
  "description": "This should be called when the user indicates they have completed a set and wants to record it.",
};

final removeSetFunctionTool = {
  "name": ExerciseLoggingFunction.removeSet.name,
  "description": "This should be called when the user wants to delete a set they have already recorded.",
};

final updateSetFunctionTool = {
  "name": ExerciseLoggingFunction.updateSet.name,
  "description": "This should be called when the user wants to change details of a previously logged set, such as the number of reps or the weight used.",
};

final openAIFunctionTools = [
  {"type": "function", "function": listExercisesFunctionTool},
  {"type": "function", "function": addSetFunctionTool},
  {"type": "function", "function": removeSetFunctionTool},
  {"type": "function", "function": updateSetFunctionTool}
];
