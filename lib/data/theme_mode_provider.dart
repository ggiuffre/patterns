import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeStateNotifier, ThemeMode>((_) => ThemeModeStateNotifier(ThemeMode.system));

/// Desired [ThemeMode], either light or dark.
class ThemeModeStateNotifier extends StateNotifier<ThemeMode> {
  ThemeModeStateNotifier(ThemeMode themeMode) : super(themeMode);

  void toggle() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  bool get light => state == ThemeMode.light;

  bool get dark => state == ThemeMode.dark;
}
