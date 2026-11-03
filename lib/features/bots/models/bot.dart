import 'package:teleforge_fe/features/commands/models/bot_command.dart';

class Bot {
  const Bot({
    required this.id,
    required this.name,
    this.username = '',
    this.isActive = true,
    this.needsSync = true,
    this.commands = const [],
  });

  final int id;
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
      name: name ?? this.name,
      username: username ?? this.username,
      isActive: isActive ?? this.isActive,
      needsSync: needsSync ?? this.needsSync,
      commands: commands ?? this.commands,
    );
  }
}
