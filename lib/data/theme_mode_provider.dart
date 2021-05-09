import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeStateNotifier, ThemeMode>((_) => ThemeModeStateNotifier());

/// Desired [ThemeMode], either light, dark or the system's default.
class ThemeModeStateNotifier extends StateNotifier<ThemeMode> {
  ThemeModeStateNotifier([ThemeMode themeMode = ThemeMode.system]) : super(themeMode);

  Future<void> setDarkMode(bool darkMode) async {
    final localStorage = await SharedPreferences.getInstance();
    state = darkMode ? ThemeMode.dark : ThemeMode.light;
    await localStorage.setBool("darkMode", darkMode);
  }

  Future<void> syncFromSharedPreferences() async {
    final localStorage = await SharedPreferences.getInstance();
    final darkMode = localStorage.getBool("darkMode");
    if (darkMode != null) {
      state = darkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  bool get light => state == ThemeMode.light;

  bool get dark => state == ThemeMode.dark;
}
