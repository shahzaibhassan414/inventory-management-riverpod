import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadSavedTheme();
    return ThemeMode.system;
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    if (saved == 'dark') {
      state = ThemeMode.dark;
    } else if (saved == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }

    _updateSystemUI(state);
  }

  void toggleTheme() async {
    final newTheme =
    state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    state = newTheme;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      newTheme == ThemeMode.dark ? 'dark' : 'light',
    );

    _updateSystemUI(newTheme);
  }

  void resetTheme() async {
    state = ThemeMode.system;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);

    _updateSystemUI(ThemeMode.system);
  }

  void _updateSystemUI(ThemeMode mode) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && brightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark ? Colors.black : null,
        systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
        statusBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}

final themeModeProvider =
NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
