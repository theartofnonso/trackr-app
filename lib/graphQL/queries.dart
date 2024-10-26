
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
    \$filter: ModelRoutineLogFilterInput
    \$limit: Int
    \$nextToken: String) {
    listRoutineLogs(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
      items {
        id
        data
        owner
        createdAt
        updatedAt
      }
      nextToken
    }
}''';