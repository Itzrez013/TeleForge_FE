import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({required this.email, super.key});

  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verify() {
    if (!RegExp(r'^\d{6}$').hasMatch(_codeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد تأیید باید ۶ رقم باشد.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('برای تأیید واقعی کد، اتصال سرور API لازم است.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأیید ایمیل')),
      body: AppResponsiveFrame(
        maxWidth: 560,
        child: SafeArea(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.cyan,
                size: 37,
              ),
            ),
            const SizedBox(height: 23),
            const Text(
              'کد تأیید را وارد کن',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'کد ۶ رقمی ارسال‌شده به این ایمیل را وارد کن:',
              style: TextStyle(color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 5),
            Text(
              widget.email,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 26),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              maxLength: 6,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 24,
                letterSpacing: 12,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '••••••',
                counterText: '',
              ),
            ),
            const SizedBox(height: 22),
            PrimaryActionButton(
              label: 'تأیید و ساخت حساب',
              icon: Icons.verified_outlined,
              onPressed: _verify,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ارسال دوباره کد پس از اتصال API فعال می‌شود.'),
                ),
              ),
              child: const Text('ارسال دوباره کد'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
