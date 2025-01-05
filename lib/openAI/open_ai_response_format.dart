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
    "name": "exercise_performance_report",
    "schema": {
      "title": "Exercise Performance Report",
      "description":
          "A structured report analyzing the user's performance on current exercises compared to previous sessions.",
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

const monthlyReportResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "monthly_training_report",
    "schema": {
      "title": "Monthly Training Report",
      "description": "A structured report summarizing the user's training performance over the past month.",
      "type": "object",
      "properties": {
        "introduction": {
          "type": "string",
          "description": "A brief introduction summarizing the overall training performance and key highlights."
        },
        "exercises_summary": {
          "type": "string",
          "description":
              "An analysis of the exercises performed, including frequency, variety, and any new exercises introduced."
        },
        "muscles_trained_summary": {
          "type": "string",
          "description": "A summary of muscle groups trained, highlighting focus areas and any potential imbalances."
        },
        "calories_burned_summary": {
          "type": "string",
          "description":
              "A summary of total calories burned, discussing energy expenditure trends and factors influencing changes."
        },
        "personal_bests_summary": {
          "type": "string",
          "description": "Details of personal bests achieved, including exercises, weights, reps, and dates."
        },
        "workout_duration_summary": {
          "type": "string",
          "description":
              "An analysis of workout durations, noting average session lengths and any significant variations."
        },
        "activities_summary": {
          "type": "string",
          "description":
              "A summary of activities logged outside of strength training, emphasizing the importance of variety."
        },
        "consistency_summary": {
          "type": "string",
          "description":
              "An evaluation of workout consistency, including frequency of training sessions and adherence to the schedule."
        },
        "recommendations": {
          "type": "string",
          "description":
              "Personalized suggestions for improving training performance, addressing weaknesses, and setting future goals."
        }
      },
      "required": [
        "introduction",
        "exercises_summary",
        "muscles_trained_summary",
        "calories_burned_summary",
        "personal_bests_summary",
        "workout_duration_summary",
        "activities_summary",
        "consistency_summary",
        "recommendations"
      ],
      "additionalProperties": false
    },
    "strict": true
  }
};
