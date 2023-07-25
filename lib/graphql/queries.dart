class GraphQLQueries {

  static const _activityFields = '''
    id
    name
    description
    createdAt
    updatedAt
    history{
      items {
        id
        activityId
        name
        description
        startTime
        endTime
        createdAt
        updatedAt
      }
    }
''';

  static const listActivitiesPath = "listActivities";
  static const listActivities = '''query listActivities(
    \$filter: ModelActivityFilterInput
    \$limit: Int
    \$nextToken: String) {
    listActivities(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
      items {
        $_activityFields
      }
      nextToken
    }
}''';
}
