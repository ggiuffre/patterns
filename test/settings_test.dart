import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/data/theme_mode_provider.dart';
import 'package:patterns/ui/components/settings.dart';

void main() {
  testWidgets("The dark mode switch is off if the system's brightness is light.", (WidgetTester tester) async {
    tester.binding.window.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: SettingsPage())));

    final darkModeSwitch = tester.widget<Switch>(find.descendant(
      of: find.widgetWithText(Card, "Dark mode"),
      matching: find.byType(Switch),
    ));
    expect(darkModeSwitch.value, false);
  });

  testWidgets("The dark mode switch is on if the system's brightness is dark.", (WidgetTester tester) async {
    tester.binding.window.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: SettingsPage())));

    final darkModeSwitch = tester.widget<Switch>(find.descendant(
      of: find.widgetWithText(Card, "Dark mode"),
      matching: find.byType(Switch),
    ));
    expect(darkModeSwitch.value, true);
  });

  testWidgets("The dark mode switch turns on if the system's brightness changes from light to dark.",
      (WidgetTester tester) async {
    tester.binding.window.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: SettingsPage())));

    expect(
        tester
            .widget<Switch>(find.descendant(
              of: find.widgetWithText(Card, "Dark mode"),
              matching: find.byType(Switch),
            ))
            .value,
        false);

    tester.binding.window.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<Switch>(find.descendant(
              of: find.widgetWithText(Card, "Dark mode"),
              matching: find.byType(Switch),
            ))
            .value,
        true);
  });

  testWidgets("The dark mode switch turns off if the system's brightness changes from dark to light.",
      (WidgetTester tester) async {
    tester.binding.window.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: SettingsPage())));

    expect(
        tester
            .widget<Switch>(find.descendant(
              of: find.widgetWithText(Card, "Dark mode"),
              matching: find.byType(Switch),
            ))
            .value,
        true);

    tester.binding.window.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<Switch>(find.descendant(
              of: find.widgetWithText(Card, "Dark mode"),
              matching: find.byType(Switch),
            ))
            .value,
        false);
  });

  testWidgets("The dark mode switch is off if the user-defined theme mode is light.", (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [themeModeProvider.overrideWithValue(ThemeModeStateNotifier(ThemeMode.light))],
      child: MaterialApp(home: SettingsPage()),
    ));

    final darkModeSwitch = tester.widget<Switch>(find.descendant(
      of: find.widgetWithText(Card, "Dark mode"),
      matching: find.byType(Switch),
    ));
    expect(darkModeSwitch.value, false);
  });

  testWidgets("The dark mode switch is on if the user-defined theme mode is dark.", (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [themeModeProvider.overrideWithValue(ThemeModeStateNotifier(ThemeMode.dark))],
      child: MaterialApp(home: SettingsPage()),
    ));

    final darkModeSwitch = tester.widget<Switch>(find.descendant(
      of: find.widgetWithText(Card, "Dark mode"),
      matching: find.byType(Switch),
    ));
    expect(darkModeSwitch.value, true);
  });

  testWidgets("The dark mode switch depends more on the user-defined theme mode than on the system's brightness.",
      (WidgetTester tester) async {
    tester.binding.window.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpWidget(ProviderScope(
      overrides: [themeModeProvider.overrideWithValue(ThemeModeStateNotifier(ThemeMode.light))],
      child: MaterialApp(home: SettingsPage()),
    ));

    final darkModeSwitch = tester.widget<Switch>(find.descendant(
      of: find.widgetWithText(Card, "Dark mode"),
      matching: find.byType(Switch),
    ));
    expect(darkModeSwitch.value, false);
  });
}
