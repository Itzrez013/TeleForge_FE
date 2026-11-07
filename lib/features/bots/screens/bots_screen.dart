import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class BotsScreen extends StatelessWidget {
  const BotsScreen({
    required this.bots,
    required this.onAddBot,
    required this.onOpenBot,
    super.key,
  });

  final List<Bot> bots;
  final VoidCallback onAddBot;
  final ValueChanged<Bot> onOpenBot;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppPageHeader(
            title: 'ربات‌های من',
            subtitle: 'مدیریت اتصال‌ها و وضعیت ربات‌ها',
            trailing: IconButton.filledTonal(
              onPressed: onAddBot,
              tooltip: 'افزودن ربات',
              icon: const Icon(Icons.add_rounded, color: Color(0xFFF4F8FF)),
            ),
          ),
          Expanded(
            child: bots.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Center(
                      child: EmptyStateCard(
                        icon: Icons.smart_toy_outlined,
                        title: 'لیست ربات‌ها خالی است',
                        message:
                            'با افزودن توکن BotFather، ربات تلگرامت را به پنل وصل کن.',
                        actionLabel: 'افزودن اولین ربات',
                        onAction: onAddBot,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900 ? 2 : 1;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: bots.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: columns == 1 ? 132 : 148,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final bot = bots[index];
                          return AppCard(
                            onTap: () => onOpenBot(bot),
                            child: Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                  child: const Icon(
                                    Icons.smart_toy_rounded,
                                    color: AppColors.cyan,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bot.name,
                                        style: const TextStyle(
                                          color: Color(0xFFF4F8FF),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        bot.username.isEmpty
                                            ? 'ربات تلگرام'
                                            : bot.username,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 9),
                                      _StatusPill(
                                        label: bot.needsSync
                                            ? 'در انتظار همگام‌سازی'
                                            : bot.isActive
                                            ? 'فعال'
                                            : 'غیرفعال',
                                        color: bot.needsSync
                                            ? AppColors.orange
                                            : bot.isActive
                                            ? AppColors.green
                                            : AppColors.muted,
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 7, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}