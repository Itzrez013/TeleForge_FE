import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class Home extends StatelessWidget {
  const Home({
    required this.bots,
    required this.onAddBot,
    required this.onOpenBot,
    required this.onViewBots,
    super.key,
  });

  final List<Bot> bots;
  final VoidCallback onAddBot;
  final ValueChanged<Bot> onOpenBot;
  final VoidCallback onViewBots;

  @override
  Widget build(BuildContext context) {
    final commandCount = bots.fold<int>(
      0,
      (total, bot) => total + bot.commands.length,
    );
    final syncCount = bots.where((bot) => bot.needsSync).length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.telegram_rounded,
                      color: AppColors.cyan,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    'TeleForge',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: 'اعلان‌ها',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('اعلان تازه‌ای ندارید.')),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.muted,
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF123B68),
                      Color(0xFF10233E),
                      Color(0xFF101827),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: .2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: AppColors.cyan,
                            size: 27,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .07),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 15,
                                color: AppColors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'پنل مدیریت',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'مدیریت ربات‌های تلگرام',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'همه ربات‌ها و پاسخ‌های خودکار را یک‌جا مدیریت کن.',
                      style: TextStyle(
                        color: Color(0xFFB0C4DE),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        _Metric(value: '${bots.length}', label: 'ربات'),
                        _Metric(value: '$commandCount', label: 'دستور'),
                        _Metric(
                          value: '$syncCount',
                          label: 'نیازمند همگام‌سازی',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: onAddBot,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          'اتصال ربات جدید',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 26, bottom: 14),
              child: AppSectionTitle(
                'ربات‌های من',
                trailing: TextButton(
                  onPressed: onViewBots,
                  child: const Text('مشاهده همه'),
                ),
              ),
            ),
          ),
          if (bots.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverToBoxAdapter(
                child: EmptyStateCard(
                  icon: Icons.smart_toy_outlined,
                  title: 'هنوز رباتی اضافه نکرده‌ای',
                  message: 'توکن ربات را از BotFather بگیر و اولین رباتت را به TeleForge وصل کن.',
                  actionLabel: 'افزودن ربات',
                  onAction: onAddBot,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: bots.length > 3 ? 3 : bots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 11),
                itemBuilder: (context, index) => _BotTile(
                  bot: bots[index],
                  onTap: () => onOpenBot(bots[index]),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
            sliver: SliverToBoxAdapter(
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: AppColors.cyan),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'توکن رباتت را محرمانه نگه دار؛ آن را با کسی به اشتراک نگذار.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _BotTile extends StatelessWidget {
  const _BotTile({required this.bot, required this.onTap});

  final Bot bot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.cyan,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bot.username.isEmpty ? 'ربات تلگرام' : bot.username,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            bot.needsSync ? Icons.sync_rounded : Icons.check_circle_rounded,
            color: bot.needsSync ? AppColors.orange : AppColors.green,
            size: 19,
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.muted,
            size: 22,
          ),
        ],
      ),
    );
  }
}
