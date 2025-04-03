enum Gender {
  male("Male"),
  female("Female"),
  nonBinary("Non-binary"),
  transgenderMale("Transgender Male"),
  transgenderFemale("Transgender Female"),
  preferNotToSay("Prefer not to say"),
  other("Other");

  const Gender(this.label);

  final String label;
}