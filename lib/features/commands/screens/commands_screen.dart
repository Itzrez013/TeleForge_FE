import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/features/commands/models/bot_command.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class CommandsScreen extends StatefulWidget {
  const CommandsScreen({
    required this.bots,
    required this.onAddCommand,
    required this.onEditCommand,
    this.initialBotId,
    super.key,
  });

  final List<Bot> bots;
  final int? initialBotId;
  final ValueChanged<Bot> onAddCommand;
  final void Function(Bot bot, BotCommand command) onEditCommand;

  @override
  State<CommandsScreen> createState() => _CommandsScreenState();
}

class _CommandsScreenState extends State<CommandsScreen> {
  int? _selectedBotId;

  @override
  void didUpdateWidget(covariant CommandsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBotId != widget.initialBotId) {
      _selectedBotId = widget.initialBotId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bot = widget.bots
        .where((item) => item.id == _selectedBotId)
        .firstOrNull;
    final selectedBot = bot ?? (widget.bots.isEmpty ? null : widget.bots.first);
    final commands = selectedBot?.commands ?? const <BotCommand>[];

    return SafeArea(
      child: Column(
        children: [
          AppPageHeader(
            title: 'دستورها',
            subtitle: 'پاسخ‌های خودکار ربات‌ها را مدیریت کن',
            trailing: selectedBot == null
                ? null
                : IconButton.filledTonal(
                    onPressed: () => widget.onAddCommand(selectedBot),
                    tooltip: 'ساخت دستور',
                    icon: const Icon(Icons.add_rounded, color: AppColors.cyan),
                  ),
          ),
          if (widget.bots.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: DropdownButtonFormField<int>(
                initialValue: selectedBot?.id,
                decoration: const InputDecoration(
                  labelText: 'انتخاب ربات',
                  prefixIcon: Icon(Icons.smart_toy_outlined),
                ),
                dropdownColor: AppColors.surfaceRaised,
                items: widget.bots
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedBotId = value),
              ),
            ),
          Expanded(
            child: selectedBot == null
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Center(
                      child: EmptyStateCard(
                        icon: Icons.terminal_rounded,
                        title: 'برای ساخت دستور، ربات اضافه کن',
                        message: 'دستورها به یک ربات تلگرام متصل می‌شوند و برای هرکدام می‌توانی یک پاسخ تعریف کنی.',
                      ),
                    ),
                  )
                : commands.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Center(
                      child: EmptyStateCard(
                        icon: Icons.code_rounded,
                        title: 'هنوز دستوری ثبت نشده',
                        message: 'دستورهایی مثل /start بساز و پاسخ دلخواهت را برایشان بنویس.',
                        actionLabel: 'ساخت اولین دستور',
                        onAction: () => widget.onAddCommand(selectedBot),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900 ? 2 : 1;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: commands.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: columns == 1 ? 136 : 154,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final command = commands[index];
                          return AppCard(
                            onTap: () =>
                                widget.onEditCommand(selectedBot, command),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.terminal_rounded,
                                    color: AppColors.cyan,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        command.name,
                                        textDirection: TextDirection.ltr,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        command.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            color: AppColors.green,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              command.response.isEmpty
                                                  ? 'بدون پاسخ'
                                                  : command.response,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_left_rounded,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
