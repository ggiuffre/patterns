import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
    () => ThemeModeController());

/// Controller for [ThemeMode].
class ThemeModeController extends AsyncNotifier<ThemeMode> {
  Future<ThemeMode> _fetchThemeMode() async {
    final localStorage = await SharedPreferences.getInstance();

    final darkMode = localStorage.getBool("darkMode");
    final themeMode = darkMode == null
        ? ThemeMode.system
        : (darkMode ? ThemeMode.dark : ThemeMode.light);

    return themeMode;
  }

  @override
  Future<ThemeMode> build() async {
    return _fetchThemeMode();
  }

  Future<void> setDarkMode(bool darkMode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final localStorage = await SharedPreferences.getInstance();
      await localStorage.setBool("darkMode", darkMode);
      return _fetchThemeMode();
    });
  }
}
