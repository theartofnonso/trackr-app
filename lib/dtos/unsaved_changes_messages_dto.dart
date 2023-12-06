
enum UnsavedChangesMessageType {
  setsLength, exerciseLogLength, exerciseLogChange, supersetId, setType, setValue,
}

class UnsavedChangesMessageDto {
  final String message;
  final UnsavedChangesMessageType type;

  UnsavedChangesMessageDto({required this.message, required this.type});

  @override
  String toString() {
    return 'UnsavedChangesMessageDto{message: $message, type: $type}';
  }
}