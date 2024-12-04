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
    "name": "exercise_performance_report",
    "schema": {
      "title": "Exercise Performance Report",
      "description":
          "A structured report analyzing the user's performance on current exercises compared to previous sessions.",
      "type": "object",
      "properties": {
        "introduction": {
          "type": "string",
          "description": "An overview summarizing the key highlights of the training report."
        },
        "exercise_reports": {
          "type": "array",
          "description": "A list of detailed reports for each exercise performed.",
          "items": {
            "type": "object",
            "properties": {
              "exercise_name": {"type": "string", "description": "The name of the exercise."},
              "current_performance": {
                "type": "object",
                "description": "Details of the current exercise performance.",
                "properties": {
                  "date": {"type": "string", "description": "The date of the current exercise session."},
                  "sets": {
                    "type": "array",
                    "description": "List of sets performed in the current session.",
                    "items": {
                      "type": "object",
                      "properties": {
                        "weight": {"type": "number", "description": "The weight used in the set."},
                        "repetitions": {
                          "type": "integer",
                          "description": "The number of repetitions performed in the set."
                        }
                      },
                      "required": ["weight", "repetitions"],
                      "additionalProperties": false
                    }
                  },
                  "total_volume": {
                    "type": "number",
                    "description":
                        "The total volume lifted in the current session (sum of weight × repetitions for all sets)."
                  }
                },
                "required": ["date", "sets", "total_volume"],
                "additionalProperties": false
              },
              "previous_performance": {
                "type": "array",
                "description": "Details of previous exercise performances for comparison.",
                "items": {
                  "type": "object",
                  "properties": {
                    "date": {"type": "string", "description": "The date of the previous exercise session."},
                    "sets": {
                      "type": "array",
                      "description": "List of sets performed in the previous session.",
                      "items": {
                        "type": "object",
                        "properties": {
                          "weight": {"type": "number", "description": "The weight used in the set."},
                          "repetitions": {
                            "type": "integer",
                            "description": "The number of repetitions performed in the set."
                          }
                        },
                        "required": ["weight", "repetitions"],
                        "additionalProperties": false
                      }
                    },
                    "total_volume": {
                      "type": "number",
                      "description": "The total volume lifted in the previous session."
                    }
                  },
                  "required": ["date", "sets", "total_volume"],
                  "additionalProperties": false
                }
              },
              "achievements": {
                "type": "string",
                "description": "A description of achievements or improvements compared to previous sessions."
              },
              "comments": {
                "type": "string",
                "description": "Overall analysis of performance trends, including notable observations."
              }
            },
            "required": ["exercise_name", "current_performance", "previous_performance", "achievements", "comments"],
            "additionalProperties": false
          }
        },
        "suggestions": {
          "type": "string",
          "description": "Personalized suggestions for future improvements and goal setting."
        }
      },
      "required": ["introduction", "exercise_reports", "suggestions"],
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

const logWeightAndRepsIntentResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "log_weight_and_repetitions_intent",
    "schema": {
      "title": "Log Weight and Repetitions Intent Action",
      "description":
          "A structured output for user action when logging weight and repetitions for a set in a workout routine.",
      "type": "object",
      "properties": {
        "weight": {"type": "number", "description": "Amount of weight lifted."},
        "repetitions": {"type": "integer", "description": "Number of repetitions."}
      },
      "required": [
        "weight",
        "repetitions",
      ],
      "additionalProperties": false
    },
    "strict": true
  }
};

const logRepsIntentResponseFormat = {
  "type": "json_schema",
  "json_schema": {
    "name": "log_repetitions_intent",
    "schema": {
      "title": "Log Repetitions Intent Action",
      "description": "A structured output for user action when logging repetitions for a set in a workout routine.",
      "type": "object",
      "properties": {
        "repetitions": {"type": "integer", "description": "Number of repetitions."}
      },
      "required": [
        "repetitions",
      ],
      "additionalProperties": false
    },
    "strict": true
  }
};
