import 'package:teleforge_fe/features/commands/models/bot_command.dart';

class Bot {
  const Bot({
    required this.id,
    required this.name,
    this.serverId,
    this.telegramId,
    this.username = '',
    this.isActive = true,
    this.needsSync = true,
    this.commands = const [],
  });

  final int id;
  final int? serverId;
  final int? telegramId;
  final String name;
  final String username;
  final bool isActive;
  final bool needsSync;
  final List<BotCommand> commands;

  Bot copyWith({
    String? name,
    String? username,
    bool? isActive,
    bool? needsSync,
    List<BotCommand>? commands,
  }) {
    return Bot(
      id: id,
      serverId: serverId,
      telegramId: telegramId,
      name: name ?? this.name,
      username: username ?? this.username,
      isActive: isActive ?? this.isActive,
      needsSync: needsSync ?? this.needsSync,
      commands: commands ?? this.commands,
    );
  }

  factory Bot.fromJson(Map<String, dynamic> json) {
    final serverId = _intValue(json['id'] ?? json['pk']);
    final telegramId = _intValue(json['bot_id']);
    return Bot(
      id: serverId ?? telegramId ?? 0,
      serverId: serverId,
      telegramId: telegramId,
      name: json['name'] as String? ?? 'ربات تلگرام',
      username: json['username'] as String? ?? '',
      isActive:
          json['is_active'] as bool? ?? json['is_acrive'] as bool? ?? true,
      needsSync: json['needs_sync'] as bool? ?? true,
    );
  }
}

int? _intValue(Object? value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');
