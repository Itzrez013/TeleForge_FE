import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/core/config/api_config.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/core/storage/token_storage.dart';
import 'package:teleforge_fe/features/auth/services/auth_service.dart';
import 'package:teleforge_fe/features/auth/screens/email_screen.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/features/bots/screens/add_bot_screen.dart';
import 'package:teleforge_fe/features/bots/screens/bot_detail_screen.dart';
import 'package:teleforge_fe/features/bots/screens/bots_screen.dart';
import 'package:teleforge_fe/features/bots/services/bot_service.dart';
import 'package:teleforge_fe/features/commands/models/bot_command.dart';
import 'package:teleforge_fe/features/commands/screens/command_form_screen.dart';
import 'package:teleforge_fe/features/commands/screens/commands_screen.dart';
import 'package:teleforge_fe/features/commands/services/command_service.dart';
import 'package:teleforge_fe/features/home/screens/home_screen.dart';
import 'package:teleforge_fe/features/profile/screens/profile_screen.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class TeleForgeShell extends StatefulWidget {
  const TeleForgeShell({this.tokenStorage, this.apiClient, super.key});

  final TokenStorage? tokenStorage;
  final ApiClient? apiClient;

  @override
  State<TeleForgeShell> createState() => _TeleForgeShellState();
}

class _TeleForgeShellState extends State<TeleForgeShell> {
  late final TokenStorage _tokenStorage =
      widget.tokenStorage ?? const TokenStorage();
  late final ApiClient _apiClient =
      widget.apiClient ?? ApiClient(tokenStorage: _tokenStorage);
  late final AuthService _authService = AuthService(
    apiClient: _apiClient,
    tokenStorage: _tokenStorage,
  );
  late final BotService _botService = BotService(_apiClient);
  late final CommandService _commandService = CommandService(_apiClient);

  int _selectedTab = 0;
  int? _selectedBotId;
  List<Bot> _bots = [];
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _profileName;
  String? _profileEmail;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final hasSession = await _authService.hasSession();
      if (!mounted) return;
      if (!hasSession) {
        setState(() => _isLoading = false);
        return;
      }
      setState(() => _isAuthenticated = true);
      await _loadDashboard();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        if (error.statusCode == 401) _isAuthenticated = false;
        _loadError = error.statusCode == 401
            ? 'نشست شما منقضی شده است. دوباره وارد حساب شو.'
            : error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboard() async {
    if (!_isAuthenticated) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final dashboard = await _apiClient.get(ApiConfig.dashboard);
      final profile = dashboard['profile'];
      final rawBots = dashboard['user_bot_list'];
      if (profile is! Map<String, dynamic> || rawBots is! List) {
        throw const ApiException(
          'Dashboard response must contain profile and user_bot_list.',
        );
      }
      final bots = <Bot>[];
      for (final rawBot in rawBots) {
        if (rawBot is! Map<String, dynamic>) {
          throw const ApiException('Dashboard contains an invalid bot record.');
        }
        final bot = Bot.fromJson(rawBot);
        if (bot.serverId == null) {
          throw const ApiException(
            'Bot responses must include the Django database id as "id".',
          );
        }
        bots.add(bot);
      }
      final hydrated = await Future.wait(
        bots.map((bot) async {
          if (bot.serverId == null) return bot;
          return _botService.loadBot(bot);
        }),
      );
      if (!mounted) return;
      setState(() {
        _bots = hydrated;
        _profileName = profile['full_name'] as String?;
        _profileEmail = profile['email'] as String?;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeAuthentication() async {
    if (!mounted) return;
    setState(() => _isAuthenticated = true);
    await _loadDashboard();
  }

  void _updateBot(Bot updated) {
    setState(() {
      _bots = _bots.map((bot) => bot.id == updated.id ? updated : bot).toList();
    });
  }

  Future<void> _addBot() async {
    if (!_isAuthenticated) {
      await _openSignIn();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            AddBotScreen(botService: _botService, onBotAdded: _loadDashboard),
      ),
    );
  }

  Future<void> _openBot(Bot bot) async {
    if (bot.serverId == null) {
      _showError(
        const ApiException(
          'The backend did not include this bot database id. Update its serializer to include "id".',
        ),
      );
      return;
    }
    _selectedBotId = bot.id;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BotDetailScreen(
          bot: bot,
          botService: _botService,
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
    if (!_isAuthenticated) return null;
    if (bot.serverId == null) {
      _showError(
        const ApiException(
          'Bot responses must include the Django database id as "id".',
        ),
      );
      return null;
    }
    if (command != null && command.serverId == null) {
      _showError(
        const ApiException(
          'Command responses must include the Django database id as "id".',
        ),
      );
      return null;
    }
    final edited = await Navigator.of(context).push<BotCommand>(
      MaterialPageRoute(
        builder: (_) => CommandFormScreen(bot: bot, command: command),
      ),
    );
    if (edited == null) return null;
    try {
      if (command == null) {
        await _commandService.addCommand(bot, edited);
      } else {
        await _commandService.updateCommand(bot, edited);
      }
      final refreshed = await _botService.loadBot(bot);
      _updateBot(refreshed);
      return refreshed.commands
          .where((item) => item.name == edited.name)
          .firstOrNull;
    } on ApiException catch (error) {
      _showError(error);
      return null;
    }
  }

  Future<void> _openSignIn() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => EmailScreen(
          authService: _authService,
          onAuthenticated: _completeAuthentication,
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.logout();
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _bots = [];
          _profileName = null;
          _profileEmail = null;
          _loadError = null;
        });
      }
    }
  }

  void _showError(ApiException error) {
    if (error.statusCode == 401 && mounted) {
      setState(() {
        _isAuthenticated = false;
        _bots = [];
        _profileName = null;
        _profileEmail = null;
      });
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.message)));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (error) {
      _showError(error);
    } on FormatException catch (error) {
      _showError(ApiException(error.message));
    }
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
      ProfileScreen(
        onSignIn: _openSignIn,
        onSignOut: _isAuthenticated ? () => _runAction(_signOut) : null,
        isAuthenticated: _isAuthenticated,
        name: _profileName,
        email: _profileEmail,
      ),
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
                return Column(
                  children: [
                    if (_loadError != null)
                      MaterialBanner(
                        content: Text(_loadError!),
                        actions: [
                          TextButton(
                            onPressed: _isAuthenticated
                                ? () => _runAction(_loadDashboard)
                                : null,
                            child: const Text('تلاش دوباره'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: contentWidth,
                                child: IndexedStack(
                                  index: _selectedTab,
                                  children: pages,
                                ),
                              ),
                            ),
                    ),
                  ],
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
