import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class AddBotScreen extends StatefulWidget {
  const AddBotScreen({super.key});

  @override
  State<AddBotScreen> createState() => _AddBotScreenState();
}

class _AddBotScreenState extends State<AddBotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _nameController = TextEditingController();
  bool _hideToken = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final enteredName = _nameController.text.trim();
    Navigator.of(context).pop(
      Bot(
        id: 0,
        name: enteredName.isEmpty ? 'ربات جدید' : enteredName,
        username: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن ربات')),
      body: AppResponsiveFrame(
        maxWidth: 760,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF123B68), Color(0xFF101827)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: .18),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.link_rounded, color: AppColors.cyan, size: 30),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اتصال امن به تلگرام',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'توکن ربات را از گفت‌وگو با BotFather دریافت کن.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'اطلاعات ربات',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tokenController,
                obscureText: _hideToken,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'توکن API ربات',
                  hintText: 'توکن دریافتی از BotFather',
                  prefixIcon: const Icon(
                    Icons.key_rounded,
                    color: AppColors.cyan,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hideToken = !_hideToken),
                    icon: Icon(
                      _hideToken
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'توکن ربات را وارد کن.'
                    : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'نام نمایشی (اختیاری)',
                  hintText: 'مثلاً ربات پشتیبانی',
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: AppColors.cyan,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.green),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'توکن دسترسی کامل به ربات می‌دهد. آن را در جای امن نگه دار.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryActionButton(
                label: 'اتصال ربات',
                icon: Icons.telegram_rounded,
                onPressed: _submit,
              ),
              const SizedBox(height: 13),
              const Text(
                'پیش‌نمایش رابط کاربری؛ برای اتصال واقعی، نشانی سرور API لازم است.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}