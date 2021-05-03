import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeStateNotifier, ThemeMode>((_) => ThemeModeStateNotifier());

/// Desired [ThemeMode], either light or dark.
class ThemeModeStateNotifier extends StateNotifier<ThemeMode> {
  ThemeModeStateNotifier() : super(ThemeMode.system);

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
