const listExercises = {
  "name": "list_exercises",
  "description":
      "Call this whenever you need to select exercises or make decisions involving exercises, please refer to the provided exercise data. Use this data to inform your choices and ensure accurate and relevant exercise recommendations",
};

const openAIFunctionTools = [
  {"type": "function", "function": listExercises}
];

const exercisesResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "exercises_response",
    "schema": {
      "type": "object",
      "properties": {
        "exercises": {
          "type": "array",
          "items": {"type": "string", "description": "Id of the exercise"},
        }
      },
      "required": ["exercises"],
      "additionalProperties": false
    },
    "strict": true
  }
};
