import 'package:logger/logger.dart';

class AppLogger extends PrettyPrinter{
  final String className;
  final String correlationId;

  AppLogger(this.className, this.correlationId);

  @override
  List<String> log(LogEvent event) {
    //final color = PrettyPrinter.defaultLevelColors[event.level];
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final message = event.message;

    /*AnsiPen pen = new AnsiPen();
    pen.red();

    print(pen("$message"));*/

    return [('[$correlationId]: $emoji: $className: $message')];

  }
}