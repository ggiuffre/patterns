import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/data/event.dart';
import 'package:patterns/data/repositories/events.dart';
import 'package:patterns/data/similarities.dart';
import 'package:patterns/ui/components/patterns_index.dart';

main() {
  final randomGenerator = Random();
  final randomDate = () => DateTime(
        randomGenerator.nextInt(200) + 1850,
        randomGenerator.nextInt(12 + 1),
        randomGenerator.nextInt(31 + 1),
      );
  final randomTitle = () => ["a", "b", "c"][randomGenerator.nextInt(3)];
  final randomEvent = () => Event(randomTitle(), randomDate());

  testWidgets("shows patterns as a list of tiles", (WidgetTester tester) async {
    final nEvents = randomGenerator.nextInt(20) + 20;
    final eventRepository = InMemoryEventRepository();
    eventRepository.events = List.generate(nEvents, (_) => randomEvent());
    final events = await eventRepository.list.last;
    final categories = events.map((e) => e.title).toSet();
    final coefficients = similarities(events, categories).reversed.toList();
    final nPatterns = coefficients.length;
    await tester.pumpWidget(ProviderScope(
      overrides: [eventProvider.overrideWithProvider(Provider((_) => eventRepository))],
      child: MaterialApp(home: Scaffold(body: PatternsIndex())),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(nPatterns));
  });
}
