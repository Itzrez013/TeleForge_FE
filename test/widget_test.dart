import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teleforge_fe/features/bots/screens/bot_detail_screen.dart';
import 'package:teleforge_fe/main.dart';

void main() {
  testWidgets('dashboard navigates to account registration and OTP', (
    tester,
  ) async {
    await tester.pumpWidget(const TeleForgeApp());
    await tester.pumpAndSettle();

    expect(find.text('مدیریت ربات‌های تلگرام'), findsOneWidget);

    await tester.tap(find.text('حساب'));
    await tester.pumpAndSettle();
    expect(find.text('کاربر مهمان'), findsOneWidget);

    await tester.tap(find.text('ورود یا ساخت حساب'));
    await tester.pumpAndSettle();
    expect(find.text('خوش برگشتی!'), findsOneWidget);

    await tester.tap(find.text('ثبت‌نام'));
    await tester.pumpAndSettle();
    expect(find.text('حساب کاربری بساز'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'کاربر آزمایشی');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('ادامه و تأیید ایمیل'));
    await tester.pumpAndSettle();

    expect(find.text('کد تأیید را وارد کن'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('uses navigation suited to phone, tablet, and desktop widths', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(const TeleForgeApp());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(800, 1024);
    await tester.pumpWidget(const TeleForgeApp());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpWidget(const TeleForgeApp());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('can add a bot and configure its command response', (
    tester,
  ) async {
    await tester.pumpWidget(const TeleForgeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('اتصال ربات جدید'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'demo-token');
    await tester.tap(find.text('اتصال ربات'));
    await tester.pumpAndSettle();

    expect(find.text('ربات جدید'), findsOneWidget);
    await tester.tap(find.text('ربات جدید'));
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
    await tester.ensureVisible(find.text('/start'));

    expect(find.text('/start'), findsOneWidget);
    await tester.ensureVisible(find.text('مشاهده همه'));
    await tester.tap(find.text('مشاهده همه'));
    await tester.pumpAndSettle();
    expect(find.text('سلام!'), findsOneWidget);
  });
}
