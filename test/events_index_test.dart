import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/repositories/event_providers.dart';
import 'package:patterns/src/ui/components/events_index.dart';

import 'factories.dart';

main() {
  testWidgets("shows events as a list of tiles", (WidgetTester tester) async {
    const nEvents = 3;
    final events = randomEvents(nEvents, title: "title", value: 1);
    await tester.pumpWidget(ProviderScope(
      overrides: [eventList.overrideWith((_) => events)],
      child:
          MaterialApp(home: Scaffold(body: EventsIndex(onEventTapped: (_) {}))),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(nEvents));
  });
}
