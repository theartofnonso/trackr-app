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

const newRoutinePlanResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "new_workout_plan_response",
    "schema": {
      "type": "object",
      "properties": {
        "plan_name": {
          "type": "string",
          "description": "The name of the workout plan"
        },
        "plan_description": {
          "type": "string",
          "description": "A short explanation of the workout plan"
        },
        "workouts": {
          "type": "array",
          "description": "A list of workouts included in the plan",
          "items": {
            "type": "object",
            "properties": {
              "workout_name": {
                "type": "string",
                "description": "A short descriptive name of the workout"
              },
              "workout_caption": {
                "type": "string",
                "description": "A short caption that explains the workout"
              },
              "exercises": {
                "type": "array",
                "items": {
                  "type": "string",
                  "description": "Ids of the exercises included in this workout"
                }
              }
            },
            "required": ["workout_name", "workout_caption", "exercises"],
            "additionalProperties": false
          }
        }
      },
      "required": ["plan_name", "plan_description", "workouts"],
      "additionalProperties": false
    },
    "strict": true
  }
};

const muscleGroupTrainingReportResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "historical_exercise_logs_response",
    "schema": {
      "title": "Exercise Performance Report",
      "description": "A structured report analyzing the user's performance on training a muscle group.",
      "type": "object",
      "properties": {
        "title": {"type": "string", "description": "The name of the current workout session."},
        "exercise_reports": {
          "type": "array",
          "description": "A list of detailed reports for each exercise performed.",
          "items": {
            "type": "object",
            "properties": {
              "exercise_id": {"type": "string", "description": "The id of the exercise."},
              "comments": {
                "type": "string",
                "description": "Overall analysis of performance trends, including notable observations."
              }
            },
            "required": ["exercise_id", "comments"],
            "additionalProperties": false
          }
        },
        "suggestions": {
          "type": "array",
          "description": "A list of personalized suggestions for future improvements.",
          "items": {
            "type": "string",
            "description": "Personalized suggestions for future improvements and goal setting."
          }
        },
      },
      "required": ["title", "exercise_reports", "suggestions"],
      "additionalProperties": false
    },
    "strict": true
  }
};

const routineLogReportResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "exercise_performance_report",
    "schema": {
      "title": "Exercise Performance Report",
      "description":
          "A structured report analyzing the user's performance on current exercises compared to previous sessions.",
      "type": "object",
      "properties": {
        "exercise_reports": {
          "type": "array",
          "description": "A list of detailed reports for each exercise performed.",
          "items": {
            "type": "object",
            "properties": {
              "exercise_id": {"type": "string", "description": "The id of the exercise."},
              "comments": {
                "type": "string",
                "description": "Overall analysis of performance trends, including notable observations."
              }
            },
            "required": ["exercise_id", "comments"],
            "additionalProperties": false
          }
        },
        "suggestions": {
          "type": "array",
          "description": "A list of personalized suggestions for future improvements.",
          "items": {
            "type": "string",
            "description": "Personalized suggestions for future improvements and goal setting."
          }
        },
      },
      "required": ["exercise_reports", "suggestions"],
      "additionalProperties": false
    },
    "strict": true
  }
};
