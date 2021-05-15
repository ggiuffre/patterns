import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/data/event.dart';
import 'package:patterns/data/repositories/events.dart';
import 'package:patterns/ui/components/events_index.dart';

main() {
  final randomGenerator = Random();
  final randomDate = () => DateTime(
        randomGenerator.nextInt(200) + 1850,
        randomGenerator.nextInt(12 + 1),
        randomGenerator.nextInt(31 + 1),
      );

  testWidgets("shows events as a list of tiles", (WidgetTester tester) async {
    const nEvents = 3;
    final eventRepository = InMemoryEventRepository();
    eventRepository.events = List.generate(nEvents, (_) => Event("title", randomDate()));
    await tester.pumpWidget(ProviderScope(
      overrides: [eventProvider.overrideWithProvider(Provider((_) => eventRepository))],
      child: MaterialApp(home: Scaffold(body: EventsIndex(onEventTapped: (_) {}))),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(nEvents));
  });
}
