enum Gender {
  male("Male"),
  female("Female"),
  nonBinary("Non-binary"),
  transgenderMale("Transgender Male"),
  transgenderFemale("Transgender Female"),
  preferNotToSay("Prefer not to say"),
  other("Other");

  const Gender(this.name);

  final String name;

  static Gender fromString(String string) {
    return values.firstWhere(
          (group) => group.name.toLowerCase() == string.toLowerCase(),
      orElse: () => Gender.other,
    );
  }
}