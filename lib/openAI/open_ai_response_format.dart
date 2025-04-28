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