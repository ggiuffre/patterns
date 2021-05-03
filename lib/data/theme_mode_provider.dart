import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeStateNotifier, ThemeMode>((_) => ThemeModeStateNotifier());

/// Desired [ThemeMode], either light or dark.
class ThemeModeStateNotifier extends StateNotifier<ThemeMode> {
  ThemeModeStateNotifier() : super(ThemeMode.system);

  void toggle() {
    if (state == ThemeMode.light) {
      print("Changing from light to dark");
      state = ThemeMode.dark;
    } else {
      print("Changing from dark to light");
      state = ThemeMode.light;
    }
  }

  bool get light => state == ThemeMode.light;

  bool get dark => state == ThemeMode.dark;
}
