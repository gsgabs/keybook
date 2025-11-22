// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:keybook/service/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('ThemeController alterna entre modos', () async {
    final themeController = ThemeController.instance;
    expect(themeController.themeMode, ThemeMode.dark);

    await themeController.toggleTheme();
    expect(themeController.themeMode, ThemeMode.light);

    await themeController.toggleTheme();
    expect(themeController.themeMode, ThemeMode.dark);
  });
}
