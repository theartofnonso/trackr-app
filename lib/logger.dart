import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'app_logger.dart';

final String uuid = Uuid().v4();

Logger getLogger({required String className}) {
  return Logger(printer: AppLogger(className.toString(), uuid));
}