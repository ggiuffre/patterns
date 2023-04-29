import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/event.dart';
import 'package:patterns/src/data/repositories/event_providers.dart';
import 'package:patterns/src/data/similarities.dart';
import 'package:patterns/src/ui/components/patterns_index.dart';

import 'factories.dart';

main() {
  testWidgets("shows a default label if patterns list is empty",
      (WidgetTester tester) async {
    const events = Iterable<Event>.empty();
    await tester.pumpWidget(ProviderScope(
      overrides: [eventList.overrideWith((_) => events)],
      child: const MaterialApp(home: Scaffold(body: PatternsIndex())),
    ));
    await tester.pumpAndSettle();

    const label = "No patterns yet";
    final widgetFinder = find.widgetWithText(Text, label);
    expect(widgetFinder, findsOneWidget);
  }, skip: true);

  testWidgets("shows patterns as a list of tiles", (WidgetTester tester) async {
    final events = randomEvents(randomInt(max: 5) + 10);
    final coefficients = similarities(events).reversed;
    await tester.pumpWidget(ProviderScope(
      overrides: [eventList.overrideWith((_) => events)],
      child: const MaterialApp(home: Scaffold(body: PatternsIndex())),
    ));
    await tester.pumpAndSettle();

    for (final similarity in coefficients) {
      final label = "${similarity.labels.first} && ${similarity.labels.last}";
      final widgetFinder = find.widgetWithText(ListTile, label);
      await tester.scrollUntilVisible(widgetFinder, 100);
      expect(widgetFinder, findsOneWidget);
    }
  }, skip: true);

  testWidgets("shows ListTile with pattern between two categories",
      (WidgetTester tester) async {
    final events = randomEvents(randomInt(max: 5) + 10, title: "a")
      ..addAll(randomEvents(randomInt(max: 5) + 10, title: "b"));
    final coefficients = similarities(events).reversed;
    await tester.pumpWidget(ProviderScope(
      overrides: [eventList.overrideWith((_) => events)],
      child: const MaterialApp(home: Scaffold(body: PatternsIndex())),
    ));
    await tester.pumpAndSettle();

    for (final similarity in coefficients) {
      final label = "${similarity.labels.first} && ${similarity.labels.last}";
      final widgetFinder = find.widgetWithText(ListTile, label);
      await tester.scrollUntilVisible(widgetFinder, 100);
      expect(widgetFinder, findsOneWidget);
    }
  }, skip: true);
}
