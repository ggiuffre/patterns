import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsStateNotifier, AppSettings>((_) => AppSettingsStateNotifier());

/// Controller for [AppSettings].
class AppSettingsStateNotifier extends StateNotifier<AppSettings> {
  AppSettingsStateNotifier({AppSettings appSettings = const AppSettings()}) : super(appSettings);

  Future<void> setDarkMode(bool darkMode) async {
    final localStorage = await SharedPreferences.getInstance();
    state = state.copyWith(themeMode: darkMode ? ThemeMode.dark : ThemeMode.light);
    await localStorage.setBool("darkMode", darkMode);
  }

  Future<void> syncFromSharedPreferences() async {
    final localStorage = await SharedPreferences.getInstance();
    final darkMode = localStorage.getBool("darkMode");
    if (darkMode != null) {
      state = state.copyWith(themeMode: darkMode ? ThemeMode.dark : ThemeMode.light);
    }
  }
}

/// User-defined settings for the app, persisted to and retrieved from disk.
class AppSettings {
  /// Desired [ThemeMode], either light, dark or the system's default.
  final ThemeMode themeMode;

  const AppSettings({this.themeMode = ThemeMode.system});

  AppSettings copyWith({ThemeMode? themeMode}) => AppSettings(themeMode: themeMode ?? this.themeMode);
}
