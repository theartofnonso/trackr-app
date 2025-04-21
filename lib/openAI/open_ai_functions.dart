
const listExercisesFunctionTool = {
  "name": "list_exercises",
  "description":
      "Call this whenever you need to select exercises or make decisions involving exercises, please refer to the provided exercise data by the user. Use this data to inform your choices and ensure accurate and relevant exercise recommendations",
};

final openAIFunctionTools = [
  {"type": "function", "function": listExercisesFunctionTool},
];
