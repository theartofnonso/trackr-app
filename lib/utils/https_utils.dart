// Mock API for UI-only mode: returns empty JSON body
Future<String> getAPI(
    {required String endpoint, Map<String, String>? queryParameters}) async {
  return '';
}
