enum TRKRGender {
  male("Male"),
  female("Female"),
  other("Other");

  const TRKRGender(this.display);

  final String display;

  static TRKRGender fromString(String string) {
    return values.firstWhere(
          (group) => group.display.toLowerCase() == string.toLowerCase(),
      orElse: () => TRKRGender.other,
    );
  }
}