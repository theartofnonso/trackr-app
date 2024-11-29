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
              "comments": {
                "type": "string",
                "description":
                "Overall summary of the exercise performance across all training sessions, including any notable trends or observations."
              }
            },
            "required": ["exercise_name", "heaviest_weight", "heaviest_volume", "comments"],
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
              "comments": {
                "type": "string",
                "description":
                "Overall summary of the exercise performance compared to previous training sessions, including any notable trends or observations."
              }
            },
            "required": ["exercise_name", "achievements", "comments"],
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