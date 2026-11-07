class BotCommand {
  const BotCommand({
    required this.id,
    required this.name,
    required this.description,
    this.serverId,
    this.responseId,
    this.hasServerResponse = false,
    this.response = '',
  });

  final int id;
  final int? serverId;
  final int? responseId;
  final bool hasServerResponse;
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
      serverId: serverId,
      responseId: responseId,
      hasServerResponse: hasServerResponse,
      name: name ?? this.name,
      description: description ?? this.description,
      response: response ?? this.response,
    );
  }

  factory BotCommand.fromJson(
    Map<String, dynamic> json, {
    required int fallbackId,
    Map<String, dynamic>? responseJson,
  }) {
    return BotCommand(
      id: _commandInt(json['id'] ?? json['pk']) ?? fallbackId,
      serverId: _commandInt(json['id'] ?? json['pk']),
      responseId: _commandInt(responseJson?['id'] ?? responseJson?['pk']),
      hasServerResponse: responseJson != null,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      response: responseJson?['text'] as String? ?? '',
    );
  }
}

int? _commandInt(Object? value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');