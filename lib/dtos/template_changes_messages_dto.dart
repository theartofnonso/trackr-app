
enum TemplateChangesMessageType {
  setsLength, exerciseLogLength, exerciseOrder, exerciseLogChange, supersetId,
}

class TemplateChangesMessageDto {
  final String message;
  final TemplateChangesMessageType type;

  TemplateChangesMessageDto({required this.message, required this.type});

  @override
  String toString() {
    return 'TemplateChangesMessageDto{message: $message, type: $type}';
  }
}