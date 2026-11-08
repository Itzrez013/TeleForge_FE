import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/core/network/api_exceptions.dart';
import 'package:teleforge_fe/features/auth/services/auth_service.dart';
import 'package:teleforge_fe/features/auth/screens/otp_screen.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({
    required this.authService,
    required this.onAuthenticated,
    super.key,
  });

  final AuthService authService;
  final Future<void> Function() onAuthenticated;

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _hidePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final email = _emailController.text.trim();
      if (_isRegister) {
        await widget.authService.register(
          fullName: _nameController.text.trim(),
          email: email,
          password: _passwordController.text,
        );
        if (mounted) {
          setState(() => _isRegister = false);
          await _openOtp(email);
        }
      } else {
        final authenticated = await widget.authService.login(
          email: email,
          password: _passwordController.text,
        );
        if (!mounted) return;
        if (authenticated) {
          await _finishAuthentication();
        } else {
          await _openOtp(email);
        }
      }
    } on ApiException catch (error) {
      _showError(error.message);
    } on FormatException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openOtp(String email) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => OtpScreen(
        email: email,
        authService: widget.authService,
        onAuthenticated: _finishAuthentication,
      ),
    ),
  );

  Future<void> _finishAuthentication() async {
    await widget.onAuthenticated();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب TeleForge'),
        actions: [
          IconButton(
            tooltip: 'بازگشت',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: AppResponsiveFrame(
        maxWidth: 560,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
            children: [
              Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.telegram_rounded,
                  color: AppColors.cyan,
                  size: 43,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isRegister ? 'حساب کاربری بساز' : 'خوش برگشتی!',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _isRegister
                    ? 'برای مدیریت یکپارچه ربات‌ها ثبت‌نام کن.'
                    : 'برای مدیریت ربات‌ها وارد حساب خودت شو.',
                style: const TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _AuthTab(
                      title: 'ورود',
                      selected: !_isRegister,
                      onTap: () => setState(() => _isRegister = false),
                    ),
                    _AuthTab(
                      title: 'ثبت‌نام',
                      selected: _isRegister,
                      onTap: () => setState(() => _isRegister = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isRegister) ...[
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'نام کامل',
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.cyan,
                          ),
                        ),
                        validator: (value) =>
                            _isRegister && (value?.trim().length ?? 0) < 3
                            ? 'نام باید حداقل ۳ نویسه باشد.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'ایمیل',
                        hintText: 'name@example.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.cyan,
                        ),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'یک آدرس ایمیل معتبر وارد کن.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'گذرواژه',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.cyan,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 8
                          ? 'گذرواژه باید حداقل ۸ نویسه باشد.'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    PrimaryActionButton(
                      label: _isRegister
                          ? 'ادامه و تأیید ایمیل'
                          : 'ورود به حساب',
                      icon: _isRegister
                          ? Icons.mark_email_read_outlined
                          : Icons.login_rounded,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'کد تأیید برای ایمیل ثبت‌شده ارسال می‌شود.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  const _AuthTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected
            ? AppColors.cyan.withValues(alpha: .13)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? AppColors.cyan : AppColors.muted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
