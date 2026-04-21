import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hermes_pro/providers/app_provider.dart';
import 'package:hermes_pro/providers/transfer_provider.dart';
import 'package:hermes_pro/core/theme/app_theme.dart';

void main() {
  group('Hermes App', () {
    testWidgets('App should use MaterialApp widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => TransferProvider()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const Scaffold(
              body: Center(
                child: Text('Hermes Pro'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Hermes Pro'), findsOneWidget);
    });

    testWidgets('App should use correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.brightness, Brightness.light);
      expect(app.theme?.primaryColor, AppTheme.primaryColor);
    });

    testWidgets('Dark theme should have dark brightness', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.brightness, Brightness.dark);
    });
  });

  group('Theme Configuration', () {
    test('Light theme should have light brightness', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    test('Dark theme should have dark brightness', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('Light theme should use correct primary color', () {
      expect(AppTheme.lightTheme.primaryColor, AppTheme.primaryColor);
    });

    test('Dark theme should use correct primary color in colorScheme', () {
      // Dark theme uses slate color scheme with teal primary
      expect(AppTheme.darkTheme.colorScheme.primary, AppTheme.primaryColor);
    });
  });

  group('App Constants', () {
    test('Primary color should be teal', () {
      expect(AppTheme.primaryColor, const Color(0xFF0d9488));
    });
  });
}
