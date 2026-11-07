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
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

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
      _bots = _bots.map((bot) => bot.id == updated.id ? updated : bot).toList();
    });
  }

  Future<void> _addBot() async {
    final bot = await Navigator.of(context)
        .push<Bot>(MaterialPageRoute(builder: (_) => const AddBotScreen()));
    if (bot == null) return;
    setState(() {
      _bots = [
        ..._bots,
        Bot(id: _nextBotId++, name: bot.name, username: bot.username),
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
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const EmailScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final isTablet = width >= AppBreakpoints.tablet;
    final pages = [
      Home(
        bots: _bots,
        onAddBot: _addBot,
        onOpenBot: _openBot,
        onViewBots: () => setState(() => _selectedTab = 1),
      ),
      BotsScreen(bots: _bots, onAddBot: _addBot, onOpenBot: _openBot),
      CommandsScreen(
        bots: _bots,
        initialBotId: _selectedBotId,
        onAddCommand: (bot) => _editCommand(bot),
        onEditCommand: (bot, command) => _editCommand(bot, command: command),
      ),
      ProfileScreen(onSignIn: _openSignIn),
    ];

    final destinations = const [
      _ShellDestination(
        icon: Icons.grid_view_rounded,
        selectedIcon: Icons.grid_view_rounded,
        label: 'خانه',
      ),
      _ShellDestination(
        icon: Icons.smart_toy_outlined,
        selectedIcon: Icons.smart_toy_rounded,
        label: 'ربات‌ها',
      ),
      _ShellDestination(
        icon: Icons.terminal_rounded,
        selectedIcon: Icons.terminal_rounded,
        label: 'دستورها',
      ),
      _ShellDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'حساب',
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            _DesktopNavigation(
              selectedIndex: _selectedTab,
              destinations: destinations,
              onSelected: (index) => setState(() => _selectedTab = index),
            )
          else if (isTablet)
            NavigationRail(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) =>
                  setState(() => _selectedTab = index),
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.cyan.withValues(alpha: .15),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final item in destinations)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(
                      item.selectedIcon,
                      color: AppColors.cyan,
                    ),
                    label: Text(item.label),
                  ),
              ],
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth > 1440
                    ? 1440.0
                    : constraints.maxWidth;
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    height: constraints.maxHeight,
                    child: IndexedStack(index: _selectedTab, children: pages),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) =>
                  setState(() => _selectedTab = index),
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.cyan.withValues(alpha: .15),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final item in destinations)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(
                      item.selectedIcon,
                      color: AppColors.cyan,
                    ),
                    label: item.label,
                  ),
              ],
            ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SizedBox(
        width: 252,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                child: Row(
                  children: [
                    const Icon(
                      Icons.telegram_rounded,
                      color: AppColors.cyan,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'TeleForge',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (var index = 0; index < destinations.length; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  child: ListTile(
                    selected: selectedIndex == index,
                    selectedTileColor: AppColors.cyan.withValues(alpha: .12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Icon(
                      selectedIndex == index
                          ? destinations[index].selectedIcon
                          : destinations[index].icon,
                      color: selectedIndex == index
                          ? AppColors.cyan
                          : AppColors.muted,
                    ),
                    title: Text(
                      destinations[index].label,
                      style: TextStyle(
                        color: selectedIndex == index
                            ? AppColors.cyan
                            : AppColors.muted,
                        fontWeight: selectedIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () => onSelected(index),
                  ),
                ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'مدیریت هوشمند ربات‌های تلگرام',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
