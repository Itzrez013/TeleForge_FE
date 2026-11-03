class BotCommand {
  const BotCommand({
    required this.id,
    required this.name,
    required this.description,
    this.response = '',
  });

  final int id;
  final String name;
  final String description;
  final String response;

  BotCommand copyWith({
    String? name,
    String? description,
    String? response,
  }) {
    return BotCommand(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      response: response ?? this.response,
    );
  }
}