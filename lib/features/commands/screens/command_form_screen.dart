import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/theme/app_colors.dart';
import 'package:teleforge_fe/features/bots/models/bot.dart';
import 'package:teleforge_fe/features/commands/models/bot_command.dart';
import 'package:teleforge_fe/shared/widgets/app_scaffold.dart';

class CommandFormScreen extends StatefulWidget {
  const CommandFormScreen({required this.bot, this.command, super.key});

  final Bot bot;
  final BotCommand? command;

  @override
  State<CommandFormScreen> createState() => _CommandFormScreenState();
}

class _CommandFormScreenState extends State<CommandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.command?.name ?? '/',
  );
  late final _descriptionController = TextEditingController(
    text: widget.command?.description ?? '',
  );
  late final _responseController = TextEditingController(
    text: widget.command?.response ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.command;
    Navigator.of(context).pop(
      BotCommand(
        id: existing?.id ?? 0,
        name: _nameController.text.trim().toLowerCase(),
        description: _descriptionController.text.trim(),
        response: _responseController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.command == null ? 'ساخت دستور' : 'ویرایش دستور'),
      ),
      body: AppResponsiveFrame(
        maxWidth: 820,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              AppCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.cyan,
                      size: 25,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ربات انتخاب‌شده',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.bot.name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              TextFormField(
                controller: _nameController,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'نام دستور',
                  hintText: '/start',
                  prefixIcon: Icon(Icons.code_rounded, color: AppColors.cyan),
                ),
                validator: (value) {
                  final command = value?.trim() ?? '';
                  if (!RegExp(r'^/[a-z0-9_]{1,31}$').hasMatch(command)) {
                    return 'از / و حروف کوچک انگلیسی، عدد یا _ استفاده کن.';
                  }
                  final duplicate = widget.bot.commands.any(
                    (item) =>
                        item.name == command &&
                        item.id != widget.command?.id,
                  );
                  if (duplicate) return 'این دستور قبلاً ثبت شده است.';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'توضیحات',
                  hintText: 'این دستور چه کاری انجام می‌دهد؟',
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                    color: AppColors.cyan,
                  ),
                ),
                validator: (value) =>
                    (value?.trim().length ?? 0) < 5
                    ? 'توضیحات باید حداقل ۵ نویسه باشد.'
                    : null,
              ),
              const SizedBox(height: 6),
              const Text(
                'پاسخ خودکار',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _responseController,
                minLines: 4,
                maxLines: 7,
                maxLength: 4096,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'متن پاسخ',
                  hintText: 'پیامی که ربات برای این دستور می‌فرستد...',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'متن پاسخ را وارد کن.'
                    : value.length > 4096
                    ? 'پاسخ نمی‌تواند بیشتر از ۴۰۹۶ نویسه باشد.'
                    : null,
              ),
              const SizedBox(height: 22),
              PrimaryActionButton(
                label: widget.command == null ? 'ذخیره دستور' : 'ثبت تغییرات',
                icon: Icons.check_rounded,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              const Text(
                'پیش‌نمایش تعاملی؛ پاسخ پس از اتصال به API به تلگرام فرستاده می‌شود.',
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