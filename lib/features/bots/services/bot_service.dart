import 'package:teleforge_fe/core/config/api_config.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/features/commands/models/bot_command.dart';

class BotService {
  const BotService(this._apiClient);

  final ApiClient _apiClient;

  Future<Bot> addBot(String token) async {
    final response = await _apiClient.post(
      ApiConfig.addBot,
      body: {'token': token},
    );
    final rawBot = response['bot'];
    if (rawBot is! Map<String, dynamic>) {
      throw const ApiException('Add-bot response is missing the bot object.');
    }
    return Bot.fromJson(rawBot);
  }

  Future<Bot> loadBot(Bot bot) async {
    final serverId = _requireServerId(bot);
    final response = await _apiClient.get(ApiConfig.bot(serverId));
    final rawBot = response['bot'];
    final rawCommands = response['commands'];
    if (rawBot is! Map<String, dynamic> || rawCommands is! List) {
      throw const ApiException('Bot detail response has an invalid shape.');
    }

    final commands = <BotCommand>[];
    for (final rawCommand in rawCommands.whereType<Map<String, dynamic>>()) {
      var command = BotCommand.fromJson(
        rawCommand,
        fallbackId: commands.length + 1,
      );
      if (command.serverId != null) {
        final commandDetail = await _apiClient.get(
          ApiConfig.command(serverId, command.serverId!),
        );
        final responseJson = commandDetail['command_responses'];
        final commandJson = commandDetail['command'];
        if (commandJson is! Map<String, dynamic>) {
          throw const ApiException(
            'Command detail response is missing its command object.',
          );
        }
        command = BotCommand.fromJson(
          commandJson,
          fallbackId: command.id,
          responseJson: responseJson is Map<String, dynamic>
              ? responseJson
              : null,
        );
      }
      commands.add(command);
    }

    final result = Bot.fromJson(rawBot).copyWith(commands: commands);
    if (result.serverId == null) {
      throw const ApiException(
        'Bot response is missing its database id; the backend serializer must include "id".',
      );
    }
    return result;
  }

  Future<void> updateBot(Bot bot) async {
    await _apiClient.patch(
      ApiConfig.bot(_requireServerId(bot)),
      body: {'name': bot.name, 'is_active': bot.isActive},
    );
  }

  Future<void> deactivateBot(Bot bot) async {
    await _apiClient.post(ApiConfig.deactivateBot(_requireServerId(bot)));
  }

  Future<void> syncBot(Bot bot) async {
    await _apiClient.post(ApiConfig.syncBot(_requireServerId(bot)));
  }

  Future<void> deleteBot(Bot bot) async {
    await _apiClient.delete(ApiConfig.bot(_requireServerId(bot)));
  }

  int _requireServerId(Bot bot) {
    final serverId = bot.serverId;
    if (serverId == null) {
      throw const ApiException(
        'This bot has no database id. The backend must include "id" in bot responses.',
      );
    }
    return serverId;
  }
}
