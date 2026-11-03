import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/features/commands/models/bot_command.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class BotDetailScreen extends StatefulWidget {
  const BotDetailScreen({
    required this.bot,
    required this.onBotChanged,
    required this.onAddCommand,
    required this.onOpenCommands,
    super.key,
  });

  final Bot bot;
  final ValueChanged<Bot> onBotChanged;
  final Future<BotCommand?> Function() onAddCommand;
  final VoidCallback onOpenCommands;

  @override
  State<BotDetailScreen> createState() => _BotDetailScreenState();
}

class _BotDetailScreenState extends State<BotDetailScreen> {
  late Bot _bot = widget.bot;

  Future<void> _addCommand() async {
    final command = await widget.onAddCommand();
    if (command == null) return;
    final commands = [
      ..._bot.commands.where((item) => item.id != command.id),
      command,
    ];
    _update(_bot.copyWith(commands: commands));
  }

  void _update(Bot updated) {
    setState(() => _bot = updated);
    widget.onBotChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = !_bot.isActive
        ? AppColors.muted
        : _bot.needsSync
        ? AppColors.orange
        : AppColors.green;
    final statusLabel = !_bot.isActive
        ? 'غیرفعال'
        : _bot.needsSync
        ? 'نیازمند همگام‌سازی'
        : 'فعال و همگام';

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت ربات'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'deactivate') {
                _update(_bot.copyWith(isActive: !_bot.isActive));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'deactivate',
                child: Text(
                  _bot.isActive ? 'غیرفعال‌کردن ربات' : 'فعال‌کردن ربات',
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            AppCard(
              padding: const EdgeInsets.all(21),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF123B68), Color(0xFF101827)],
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.cyan,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _bot.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _bot.username.isEmpty ? 'ربات تلگرام' : _bot.username,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 14),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: statusColor),
                          const SizedBox(width: 7),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 21),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.terminal_rounded,
                    value: '${_bot.commands.length}',
                    label: 'دستور',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.sync_rounded,
                    value: _bot.needsSync ? 'در انتظار' : 'به‌روز',
                    label: 'وضعیت اتصال',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            AppSectionTitle('ابزارهای ربات'),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.sync_rounded,
              title: 'همگام‌سازی ربات',
              subtitle: 'ثبت دستورها و وب‌هوک در تلگرام',
              onTap: () => _update(_bot.copyWith(needsSync: false)),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.terminal_rounded,
              title: 'مدیریت دستورها',
              subtitle: 'ساخت پاسخ خودکار برای دستورها',
              onTap: widget.onOpenCommands,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: _bot.isActive
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              title: _bot.isActive ? 'غیرفعال‌کردن ربات' : 'فعال‌کردن ربات',
              subtitle: 'تغییر وضعیت دسترسی ربات',
              onTap: () => _update(_bot.copyWith(isActive: !_bot.isActive)),
              color: _bot.isActive ? AppColors.orange : AppColors.green,
            ),
            const SizedBox(height: 24),
            AppSectionTitle(
              'دستورهای اخیر',
              trailing: TextButton(
                onPressed: widget.onOpenCommands,
                child: const Text('مشاهده همه'),
              ),
            ),
            const SizedBox(height: 12),
            if (_bot.commands.isEmpty)
              EmptyStateCard(
                icon: Icons.terminal_rounded,
                title: 'هنوز دستوری نساخته‌ای',
                message: 'برای پاسخ‌گویی خودکار، اولین دستور این ربات را بساز.',
                actionLabel: 'ساخت دستور',
                onAction: _addCommand,
              )
            else
              ..._bot.commands
                  .take(3)
                  .map(
                    (command) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: AppCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.code_rounded,
                              color: AppColors.cyan,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    command.name,
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    command.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            const Text(
              'پیش‌نمایش تعاملی؛ تغییرات در سرور ذخیره نمی‌شوند.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.cyan, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.cyan,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
