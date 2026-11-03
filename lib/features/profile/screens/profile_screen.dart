import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.onSignIn, super.key});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          const AppPageHeader(
            title: 'حساب کاربری',
            subtitle: 'اطلاعات و تنظیمات حساب',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: const EdgeInsets.all(20),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF123B68), Color(0xFF101827)],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: .15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: .3),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.cyan,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'کاربر مهمان',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'برای همگام‌سازی اطلاعات وارد حساب شو',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onSignIn,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('ورود یا ساخت حساب'),
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
          const Padding(
            padding: EdgeInsets.only(top: 27, bottom: 12),
            child: AppSectionTitle('تنظیمات'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _ProfileOption(
                  icon: Icons.notifications_none_rounded,
                  title: 'اعلان‌ها',
                  subtitle: 'مدیریت اعلان‌های ربات',
                  onTap: () => _message(context, 'تنظیم اعلان‌ها به‌زودی فعال می‌شود.'),
                ),
                const SizedBox(height: 10),
                _ProfileOption(
                  icon: Icons.shield_outlined,
                  title: 'امنیت و حریم خصوصی',
                  subtitle: 'اطلاعات حساب و نشست‌ها',
                  onTap: () => _message(
                    context,
                    'توکن‌های ربات را محرمانه نگه دار.',
                  ),
                ),
                const SizedBox(height: 10),
                _ProfileOption(
                  icon: Icons.help_outline_rounded,
                  title: 'راهنمای TeleForge',
                  subtitle: 'مدیریت ربات و دستورهای تلگرام',
                  onTap: () => _message(
                    context,
                    'از BotFather توکن بگیر، ربات را وصل کن و پاسخ دستورها را بساز.',
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 26),
            child: Center(
              child: Text(
                'TeleForge  •  نسخه ۱.۰',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.cyan, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
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