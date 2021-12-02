import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/repositories/events.dart';
import 'package:patterns/src/data/similarities.dart';
import 'package:patterns/src/ui/components/patterns_index.dart';

import 'factories.dart';

main() {
  testWidgets("shows patterns as a list of tiles", (WidgetTester tester) async {
    final eventRepository = InMemoryEventRepository();
    eventRepository.events = randomEvents(randomInt(max: 20) + 10);
    final events = await eventRepository.list.last;
    final categories = events.map((e) => e.title).toSet();
    final coefficients = similarities(events, categories: categories).reversed.toList();
    await tester.pumpWidget(ProviderScope(
      overrides: [eventProvider.overrideWithProvider(Provider((_) => eventRepository))],
      child: const MaterialApp(home: Scaffold(body: PatternsIndex())),
    ));
    await tester.pumpAndSettle();

    for (var similarity in coefficients) {
      final label = "${similarity.labels.first} && ${similarity.labels.last}";
      final widgetFinder = find.widgetWithText(ListTile, label);
      await tester.scrollUntilVisible(widgetFinder, 100);
      expect(widgetFinder, findsOneWidget);
    }
  });
}
