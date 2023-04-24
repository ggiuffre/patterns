import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/theme_mode_provider.dart';
import 'package:patterns/src/ui/components/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group("The dark mode switch", () {
    testWidgets("has a title.", (WidgetTester tester) async {
      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.light;
      await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(home: DarkModeSettingsCard())));

      final darkModeSwitch = tester.widget<Text>(find.byType(Text));
      expect(darkModeSwitch.data, "Dark mode");
    });

    testWidgets("is off if the system's brightness is light.",
        (WidgetTester tester) async {
      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.light;
      await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(home: DarkModeSettingsCard())));

      final darkModeSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(darkModeSwitch.value, false);
    });

    testWidgets("is on if the system's brightness is dark.",
        (WidgetTester tester) async {
      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;
      await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(home: DarkModeSettingsCard())));

      final darkModeSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(darkModeSwitch.value, true);
    });

    testWidgets(
        "turns on if the system's brightness changes from light to dark.",
        (WidgetTester tester) async {
      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.light;
      await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(home: DarkModeSettingsCard())));

      expect(tester.widget<Switch>(find.byType(Switch)).value, false);

      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, true);
    });

    testWidgets(
        "turns off if the system's brightness changes from dark to light.",
        (WidgetTester tester) async {
      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;
      await tester.pumpWidget(const ProviderScope(
          child: MaterialApp(home: DarkModeSettingsCard())));

      expect(tester.widget<Switch>(find.byType(Switch)).value, true);

      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.light;
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, false);
    });

    testWidgets("is off if the user-defined theme mode is light.",
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({"darkMode": false});
      await tester.pumpWidget(ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(() => ThemeModeController())
        ],
        child: const MaterialApp(home: DarkModeSettingsCard()),
      ));
      await tester.pumpAndSettle();

      final darkModeSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(darkModeSwitch.value, false);
    });

    testWidgets("is on if the user-defined theme mode is dark.",
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({"darkMode": true});
      await tester.pumpWidget(ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(() => ThemeModeController())
        ],
        child: const MaterialApp(home: DarkModeSettingsCard()),
      ));
      await tester.pumpAndSettle();

      final darkModeSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(darkModeSwitch.value, true);
    });

    testWidgets(
        "depends more on the user-defined theme mode than on the system's brightness.",
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({"darkMode": false});
      tester.binding.window.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(() => ThemeModeController())
        ],
        child: const MaterialApp(home: DarkModeSettingsCard()),
      ));
      await tester.pumpAndSettle();

      final darkModeSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(darkModeSwitch.value, false);
    });
  });
}
