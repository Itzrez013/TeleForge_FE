import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/features/auth/screens/email_screen.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/features/bots/screens/add_bot_screen.dart';
import 'package:teleforge_fe/features/bots/screens/bot_detail_screen.dart';
import 'package:teleforge_fe/features/bots/screens/bots_screen.dart';
import 'package:teleforge_fe/features/commands/models/bot_command.dart';
import 'package:teleforge_fe/features/commands/screens/command_form_screen.dart';
import 'package:teleforge_fe/features/commands/screens/commands_screen.dart';
import 'package:teleforge_fe/features/home/screens/home_screen.dart';
import 'package:teleforge_fe/features/profile/screens/profile_screen.dart';

class TeleForgeShell extends StatefulWidget {
  const TeleForgeShell({super.key});

  @override
  State<TeleForgeShell> createState() => _TeleForgeShellState();
}

class _TeleForgeShellState extends State<TeleForgeShell> {
  int _selectedTab = 0;
  int? _selectedBotId;
  int _nextBotId = 1;
  int _nextCommandId = 1;
  List<Bot> _bots = [];

  void _updateBot(Bot updated) {
    setState(() {
      _bots = _bots
          .map((bot) => bot.id == updated.id ? updated : bot)
          .toList();
    });
  }

  Future<void> _addBot() async {
    final bot = await Navigator.of(context).push<Bot>(
      MaterialPageRoute(builder: (_) => const AddBotScreen()),
    );
    if (bot == null) return;
    setState(() {
      _bots = [
        ..._bots,
        Bot(
          id: _nextBotId++,
          name: bot.name,
          username: bot.username,
        ),
      ];
    });
  }

  Future<void> _openBot(Bot bot) async {
    _selectedBotId = bot.id;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BotDetailScreen(
          bot: bot,
          onBotChanged: _updateBot,
          onAddCommand: () => _editCommand(bot),
          onOpenCommands: () {
            Navigator.of(context).pop();
            setState(() => _selectedTab = 2);
          },
        ),
      ),
    );
  }

  Future<BotCommand?> _editCommand(Bot bot, {BotCommand? command}) async {
    final edited = await Navigator.of(context).push<BotCommand>(
      MaterialPageRoute(
        builder: (_) => CommandFormScreen(bot: bot, command: command),
      ),
    );
    if (edited == null) return null;
    final existing = bot.commands.indexWhere((item) => item.id == edited.id);
    final commands = [...bot.commands];
    late final BotCommand saved;
    if (existing < 0) {
      saved = BotCommand(
        id: _nextCommandId++,
        name: edited.name,
        description: edited.description,
        response: edited.response,
      );
      commands.add(saved);
    } else {
      commands[existing] = edited;
      saved = edited;
    }
    _updateBot(bot.copyWith(commands: commands));
    return saved;
  }

  Future<void> _openSignIn() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const EmailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Home(
        bots: _bots,
        onAddBot: _addBot,
        onOpenBot: _openBot,
        onViewBots: () => setState(() => _selectedTab = 1),
      ),
      BotsScreen(
        bots: _bots,
        onAddBot: _addBot,
        onOpenBot: _openBot,
      ),
      CommandsScreen(
        bots: _bots,
        initialBotId: _selectedBotId,
        onAddCommand: (bot) => _editCommand(bot),
        onEditCommand: (bot, command) =>
            _editCommand(bot, command: command),
      ),
      ProfileScreen(onSignIn: _openSignIn),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedTab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.cyan.withValues(alpha: .15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.cyan),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded, color: AppColors.cyan),
            label: 'ربات‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_rounded),
            selectedIcon: Icon(Icons.terminal_rounded, color: AppColors.cyan),
            label: 'دستورها',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.cyan),
            label: 'حساب',
          ),
        ],
      ),
    );
  }
}