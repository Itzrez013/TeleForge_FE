import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:teleforge_fe/core/network/api_client.dart';
import 'package:teleforge_fe/core/storage/token_storage.dart';
import 'package:teleforge_fe/features/bots/screens/bot_detail_screen.dart';
import 'package:teleforge_fe/main.dart';

void main() {
  testWidgets('registers, verifies OTP, and loads the authenticated account', (
    tester,
  ) async {
    final backend = _FakeBackend();
    await tester.pumpWidget(_app(backend));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ورود یا ساخت حساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ثبت‌نام'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'کاربر آزمایشی');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('ادامه و تأیید ایمیل'));
    await tester.pumpAndSettle();
    expect(find.text('کد تأیید را وارد کن'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.text('تأیید و ساخت حساب'));
    await tester.pumpAndSettle();

    expect(find.text('test@example.com'), findsOneWidget);
    expect(backend.paths, contains('/register/'));
    expect(backend.paths, contains('/register/otp/'));
    expect(backend.paths, contains('/dashboard/'));
  });

  testWidgets('uses navigation suited to phone, tablet, and desktop widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(_app(_FakeBackend()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(800, 1024);
    await tester.pumpWidget(_app(_FakeBackend()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpWidget(_app(_FakeBackend()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates bots and commands through the API', (tester) async {
    final backend = _FakeBackend();
    await tester.pumpWidget(_app(backend));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حساب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ورود یا ساخت حساب'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('ورود به حساب'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('خانه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اتصال ربات جدید'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'demo-token');
    await tester.tap(find.text('اتصال ربات'));
    await tester.pumpAndSettle();

    expect(find.text('Demo Bot'), findsOneWidget);
    await tester.tap(find.text('Demo Bot'));
    await tester.pumpAndSettle();
    final botDetailScroll = find.descendant(
      of: find.byType(BotDetailScreen),
      matching: find.byType(Scrollable),
    );
    await tester.drag(botDetailScroll, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ساخت دستور'));
    await tester.tap(find.text('ساخت دستور'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '/start');
    await tester.enterText(find.byType(TextFormField).at(1), 'شروع گفتگو');
    await tester.enterText(find.byType(TextFormField).at(2), 'سلام!');
    await tester.tap(find.text('ذخیره دستور'));
    await tester.pumpAndSettle();

    expect(backend.paths, contains('/get-token/'));
    expect(backend.paths, contains('/bots/7/commands/21/'));
    await tester.ensureVisible(find.text('مشاهده همه'));
    await tester.tap(find.text('مشاهده همه'));
    await tester.pumpAndSettle();
    expect(find.text('سلام!'), findsOneWidget);
  });
}

Widget _app(_FakeBackend backend) {
  final tokenStorage = _MemoryTokenStorage();
  return TeleForgeApp(
    tokenStorage: tokenStorage,
    apiClient: ApiClient(
      tokenStorage: tokenStorage,
      httpClient: MockClient(backend.handle),
      baseUrl: 'https://api.example.test',
    ),
  );
}

class _MemoryTokenStorage extends TokenStorage {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

class _FakeBackend {
  final paths = <String>[];
  bool _botAdded = false;
  bool _commandAdded = false;
  String _commandName = '/start';
  String _commandDescription = 'شروع گفتگو';

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    paths.add(path);
    final body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;
    switch ('${request.method} $path') {
      case 'POST /register/':
        return _json({'message': 'Verification code sent.'}, 201);
      case 'POST /register/otp/':
      case 'POST /login/':
        return _json({'access': 'access-token', 'refresh': 'refresh-token'});
      case 'GET /dashboard/':
        return _json({
          'profile': {'email': 'test@example.com', 'full_name': 'Test User'},
          'user_bot_list': _botAdded ? [_botJson] : [],
        });
      case 'POST /get-token/':
        _botAdded = true;
        return _json({'bot': _botJson}, 201);
      case 'GET /bots/7/':
        return _json({
          'bot': _botJson,
          'commands': _commandAdded ? [_commandJson] : [],
        });
      case 'POST /bots/7/':
        _commandAdded = true;
        _commandName = body['name'] as String;
        _commandDescription = body['description'] as String;
        return _json({'message': 'Command created.'}, 201);
      case 'POST /bots/7/commands/21/':
        return _json({
          'response': {'id': 31, 'text': body['text']},
        }, 201);
      case 'GET /bots/7/commands/21/':
        return _json({
          'command': _commandJson,
          'command_responses': {'id': 31, 'text': 'سلام!'},
        });
      default:
        return _json({'detail': 'Unexpected test request: $path'}, 404);
    }
  }

  Map<String, dynamic> get _botJson => {
    'id': 7,
    'bot_id': 123456,
    'name': 'Demo Bot',
    'username': 'demo_bot',
    'is_active': true,
    'needs_sync': false,
  };

  Map<String, dynamic> get _commandJson => {
    'id': 21,
    'bot': 7,
    'name': _commandName,
    'description': _commandDescription,
  };

  http.Response _json(Object body, [int statusCode = 200]) => http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}
