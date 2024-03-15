
const deleteUserExerciseData = '''mutation BatchDeleteExerciseData {
    deleteUserExerciseData
}''';

const deleteUserRoutineTemplateData = '''mutation BatchDeleteUserRoutineTemplateData {
    deleteUserRoutineTemplateData
}''';

const deleteUserRoutineLogData = '''mutation BatchDeleteUserRoutineLogData {
    deleteUserRoutineLogData
}''';

const listRoutineLogsPath = "listRoutineLogs";
const listRoutineLogs = '''query ListRoutineLogs(
    \$filter: ModelEventFilterInput
    \$limit: Int
    \$nextToken: String) {
    listEvents(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
      items {
        id
        owner
        data
        createdAt
        updatedAt
      }
      nextToken
    }
}''';