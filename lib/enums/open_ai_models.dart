enum OpenAIModel {
  fourO(name: "gpt-4o"), fourOMini(name: "gpt-4o-mini"), whisper(name: "whisper-1");

  final String name;

  const OpenAIModel({required this.name});
}