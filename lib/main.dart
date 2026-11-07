import 'package:flutter/material.dart';
import 'package:teleforge_fe/app/app.dart';
import 'package:teleforge_fe/app/theme/app_theme.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/storage/token_storage.dart';

void main() {
  runApp(const TeleForgeApp());
}

class TeleForgeApp extends StatelessWidget {
  const TeleForgeApp({this.tokenStorage, this.apiClient, super.key});

  final TokenStorage? tokenStorage;
  final ApiClient? apiClient;

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
      home: TeleForgeShell(
        tokenStorage: tokenStorage,
        apiClient: apiClient,
      ),
    );
  }
}
