import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
    () => ThemeModeController());

final _logger = Logger((ThemeModeController).toString());

/// Controller for [ThemeMode].
class ThemeModeController extends AsyncNotifier<ThemeMode> {
  Future<ThemeMode> _fetchThemeMode() async {
    final localStorage = await SharedPreferences.getInstance();

    try {
      final darkMode = localStorage.getBool("darkMode");
      final themeMode = darkMode == null
          ? ThemeMode.system
          : (darkMode ? ThemeMode.dark : ThemeMode.light);

      return themeMode;
    } catch (error, stackTrace) {
      _logger.severe("Error reading from local storage", error, stackTrace);
      return ThemeMode.system;
    }
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
