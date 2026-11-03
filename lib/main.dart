import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/app.dart';
import 'package:teleforge_fe/app/theme/app_theme.dart';

void main() {
  runApp(const TeleForgeApp());
}

class TeleForgeApp extends StatelessWidget {
  const TeleForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeleForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const TeleForgeShell(),
    );
  }
}
