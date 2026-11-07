import 'package:teleforge_fe/core/config/api_config.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/features/commands/models/bot_command.dart';

class CommandService {
  const CommandService(this._apiClient);

  final ApiClient _apiClient;

  Future<BotCommand> addCommand(Bot bot, BotCommand command) async {
    final botId = _requireBotId(bot);
    await _apiClient.post(
      ApiConfig.bot(botId),
      body: {'name': command.name, 'description': command.description},
    );
    final created = await _findCommand(bot, command.name);
    await _createResponse(botId, created, command.response);
    return created.copyWith(response: command.response);
  }

  Future<BotCommand> updateCommand(Bot bot, BotCommand command) async {
    final botId = _requireBotId(bot);
    final commandId = _requireCommandId(command);
    if (command.hasServerResponse && command.responseId == null) {
      throw const ApiException(
        'The backend must include the response database id as "id" to edit an existing response.',
      );
    }
    await _apiClient.patch(
      ApiConfig.command(botId, commandId),
      body: {'name': command.name, 'description': command.description},
    );
    if (command.responseId == null) {
      await _createResponse(botId, command, command.response);
    } else {
      await _apiClient.patch(
        ApiConfig.response(botId, commandId, command.responseId!),
        body: {'text': command.response},
      );
    }
    return command;
  }

  Future<void> deleteCommand(Bot bot, BotCommand command) =>
      _apiClient.delete(
        ApiConfig.command(_requireBotId(bot), _requireCommandId(command)),
      );

  Future<BotCommand> _findCommand(Bot bot, String name) async {
    final detail = await _apiClient.get(ApiConfig.bot(_requireBotId(bot)));
    final rawCommands = detail['commands'];
    if (rawCommands is! List) {
      throw const ApiException('Bot detail response has no commands list.');
    }
    final rawCommand = rawCommands
        .whereType<Map<String, dynamic>>()
        .where((item) => item['name'] == name)
        .firstOrNull;
    if (rawCommand == null) {
      throw const ApiException('The newly created command was not returned.');
    }
    final command = BotCommand.fromJson(
      rawCommand,
      fallbackId: 0,
    );
    if (command.serverId == null) {
      throw const ApiException(
        'Command response is missing its database id; the backend serializer must include "id".',
      );
    }
    return command;
  }

  Future<void> _createResponse(
    int botId,
    BotCommand command,
    String response,
  ) async {
    await _apiClient.post(
      ApiConfig.command(botId, _requireCommandId(command)),
      body: {'text': response},
    );
  }

  int _requireBotId(Bot bot) {
    final id = bot.serverId;
    if (id == null) {
      throw const ApiException(
        'This bot has no database id. The backend must include "id" in bot responses.',
      );
    }
    return id;
  }

  int _requireCommandId(BotCommand command) {
    final id = command.serverId;
    if (id == null) {
      throw const ApiException(
        'This command has no database id. The backend must include "id" in command responses.',
      );
    }
    return id;
  }
}