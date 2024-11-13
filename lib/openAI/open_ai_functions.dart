const _listExercisesFunctionTool = {
  "name": "list_exercises",
  "description":
      "Call this whenever you need to select exercises or make decisions involving exercises, please refer to the provided exercise data. Use this data to inform your choices and ensure accurate and relevant exercise recommendations",
};

const openAIFunctionTools = [
  {"type": "function", "function": _listExercisesFunctionTool}
];

const newRoutineTemplateResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "new_workout_response",
    "schema": {
      "type": "object",
      "properties": {
        "exercises": {
          "type": "array",
          "items": {"type": "string", "description": "Ids of the exercises found in the list of exercises provided"},
        },
        "workout_name": {"type": "string", "description": "The descriptive name of the workout"},
        "workout_caption": {"type": "string", "description": "A brief caption that summarises the workout"}
      },
      "required": ["exercises", "workout_name", "workout_caption"],
      "additionalProperties": false
    },
    "strict": true
  }
};

const exercisesRecommendationResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "exercises_recommendation_response",
    "description": "A response format providing exercise recommendations for each muscle group provided by the user.",
    "schema": {
      "type": "object",
      "properties": {
        "exercises": {
          "type": "array",
          "description": "List of muscle groups with their corresponding recommendations.",
          "items": {
            "type": "object",
            "properties": {
              "muscle_group": {"type": "string", "description": "Name of the muscle group provided by the user."},
              "recommended_exercises": {
                "type": "array",
                "description": "Array containing the Ids of 2 exercise recommendations",
                "items": {
                  "type": "string",
                  "description": "Ids of the recommended exercises found in the list of exercises provided"
                },
              },
              "rationale": {
                "type": "string",
                "description": "Brief caption explaining the reason for the recommendation"
              }
            },
            "required": ["muscle_group", "recommended_exercises", "rationale"],
            "additionalProperties": false
          },
        },
      },
      "required": ["exercises"],
      "additionalProperties": false
    },
    "strict": true
  }
};

const newRoutinePlanResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "new_workout_plan_response",
    "schema": {
      "type": "object",
      "properties": {
        "workouts": {
          "type": "array",
          "description": "List of workouts for a week.",
          "items": {
            "type": "object",
            "properties": {
              "exercises": {
                "type": "array",
                "items": {"type": "string", "description": "Ids of the exercises found in the list of exercises provided"},
              },
              "workout_name": {"type": "string", "description": "The descriptive name of the workout"},
              "workout_caption": {"type": "string", "description": "A brief caption that summarises the workout"}
            },
            "required": ["exercises", "workout_name", "workout_caption"],
            "additionalProperties": false
          }
        },
        "workout_plan_name": {"type": "string", "description": "The descriptive name of the workout"},
        "workout_plan_caption": {"type": "string", "description": "A brief caption that summarises the workout"}
      },
      "required": ["workouts", "workout_plan_name", "workout_plan_caption"],
      "additionalProperties": false
    },
    "strict": true
  }
};
