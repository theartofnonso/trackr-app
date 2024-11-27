const listExercisesFunctionTool = {
  "name": "list_exercises",
  "description":
      "Call this whenever you need to select exercises or make decisions involving exercises, please refer to the provided exercise data. Use this data to inform your choices and ensure accurate and relevant exercise recommendations",
};

const openAIFunctionTools = [
  {"type": "function", "function": listExercisesFunctionTool}
];

const newRoutineResponseFormat = {
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

const routineLogsReportResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "historical_exercise_logs_response",
    "schema": {
      "type": "object",
      "properties": {
        "introduction": {
          "type": "string",
          "description": "Brief introduction summarizing the overall training report."
        },
        "exercise_reports": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "exercise_name": {"type": "string", "description": "The name of the exercise."},
              "heaviest_weight": {
                "type": "string",
                "description": "Summary of heaviest weight lifted for this exercise."
              },
              "heaviest_volume": {
                "type": "string",
                "description": "Summary of heaviest total volume (weight x reps) lifted for this exercise."
              },
              "drops_in_performance": {
                "type": "array",
                "description":
                "List of brief summary of training sessions where there was a decline in performance compared to previous sessions.",
                "items": {"type": "string", "description": "Description of the drop in performance compared to previous sessions."}
              },
              "comments": {
                "type": "string",
                "description":
                "Overall summary of the exercise performance across all training sessions, including any notable trends or observations."
              }
            },
            "required": ["exercise_name", "heaviest_weight", "heaviest_volume", "drops_in_performance", "comments"],
            "additionalProperties": false
          }
        },
        "suggestions": {"type": "string", "description": "Brief summary of suggestions for future improvements."}
      },
      "required": ["introduction", "exercise_reports", "suggestions"],
      "additionalProperties": false
    },
    "strict": true
  }
};

const routineLogReportResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "current_exercise_logs_response",
    "schema": {
      "type": "object",
      "properties": {
        "introduction": {
          "type": "string",
          "description": "Brief introduction summarizing the overall training report."
        },
        "exercise_reports": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "exercise_name": {"type": "string", "description": "The name of the exercise."},
              "achievements": {
                "type": "array",
                "description":
                "List of brief summary of training sessions where there was an improvement in performance across sets compared to previous sessions.",
                "items": {"type": "string", "description": "Description of an improvement in performance across sets compared to previous sessions."}
              },
              "improvements": {
                "type": "array",
                "description":
                "List of brief summary of training sessions where there was a decline in performance across sets compared to previous sessions.",
                "items": {"type": "string", "description": "Description of an decline in performance across sets compared to previous sessions."}
              },
              "comments": {
                "type": "string",
                "description":
                "Overall summary of the exercise performance compared to previous training sessions, including any notable trends or observations."
              }
            },
            "required": ["exercise_name", "achievements", "improvements", "comments"],
            "additionalProperties": false
          }
        },
        "suggestions": {"type": "string", "description": "Brief summary of suggestions for future improvements."}
      },
      "required": ["introduction", "exercise_reports", "suggestions"],
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
              "muscle_group": {
                "type": "string",
                "description": "Name of the muscle group provided by the user."
              },
              "recommended_exercises": {
                "type": "array",
                "description": "Array containing the Ids of 2 exercise recommendations",
                "items": {"type": "string", "description": "Ids of the recommended exercises found in the list of exercises provided"},
              },
              "rationale": {"type": "string", "description": "Brief caption explaining the reason for the recommendation"}
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
