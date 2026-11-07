import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/features/bots/services/bot_service.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class AddBotScreen extends StatefulWidget {
  const AddBotScreen({
    required this.botService,
    required this.onBotAdded,
    super.key,
  });

  final BotService botService;
  final Future<void> Function() onBotAdded;

  @override
  State<AddBotScreen> createState() => _AddBotScreenState();
}

class _AddBotScreenState extends State<AddBotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _hideToken = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.botService.addBot(_tokenController.text.trim());
      await widget.onBotAdded();
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      _showError(error.message);
    } on FormatException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 13),
                const Text(
                  'توکن به‌صورت امن به سرور ارسال می‌شود و ذخیرهٔ محلی نخواهد شد.',
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
