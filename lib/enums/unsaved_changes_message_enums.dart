
enum UnsavedChangesMessageEnum {
  addedProcedure("Added new exercise(s)");
  
  const UnsavedChangesMessageEnum(this.message);

  final String message;

  static UnsavedChangesMessageEnum fromString(String string) {
    return UnsavedChangesMessageEnum.values.firstWhere((value) => value.name == string);
  }
}