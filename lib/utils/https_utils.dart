import 'package:amplify_flutter/amplify_flutter.dart';


Future<String> getAPI({required String endpoint}) async {
  final restOperation = Amplify.API.get(endpoint);
  try {
    await restOperation.response;
  } on ApiException catch (e) {
    safePrint('Failed to get data from API: $e');
  }
  final restResponse = await restOperation.response;
  return restResponse.decodeBody();
}