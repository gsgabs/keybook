import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static ThemeController? _instance;
  static ThemeController get instance {
    _instance ??= ThemeController._();
    return _instance!;
  }
  static const _storageKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_storageKey);

    if (storedMode != null) {
      try {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == storedMode,
          orElse: () => ThemeMode.dark,
        );
      } catch (_) {
        _themeMode = ThemeMode.dark;
      }
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }
}
