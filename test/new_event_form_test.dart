import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/data/repositories/events.dart';
import 'package:patterns/ui/components/new_event_form.dart';

main() {
  group("The new-event form", () {
    testWidgets("shows a text field to enter a title", (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => const DummyEventRepository()))],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.widgetWithText(TextFormField, "Event title"), findsOneWidget);
    });

    testWidgets("shows a text field to enter a time", (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => const DummyEventRepository()))],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.widgetWithText(TextFormField, "Event time"), findsOneWidget);
    });

    testWidgets("shows a radio list to select a frequency", (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => const DummyEventRepository()))],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets("shows a submit button", (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => const DummyEventRepository()))],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.widgetWithText(ElevatedButton, "Submit"), findsOneWidget);
    });

    testWidgets("shows a progress indicator upon form submission", (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => const DummyEventRepository()))],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      await tester.enterText(find.widgetWithText(TextFormField, "Event title"), "title");
      await tester.tap(find.widgetWithText(ElevatedButton, "Submit"));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets("executes a callback upon form submission", (WidgetTester tester) async {
      bool formSubmitted = false;
      final onSubmit = () => formSubmitted = true;
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => const DummyEventRepository()))],
        child: MaterialApp(home: NewEventForm(onSubmit: onSubmit)),
      ));

      await tester.enterText(find.widgetWithText(TextFormField, "Event title"), "title");
      await tester.tap(find.widgetWithText(ElevatedButton, "Submit"));
      await tester.pump();
      expect(formSubmitted, true);
    });

    testWidgets("shows an error if the event title is empty upon submission", (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => const DummyEventRepository()))],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      await tester.tap(find.widgetWithText(ElevatedButton, "Submit"));
      await tester.pump();
      expect(find.text("Please enter a title for this event"), findsOneWidget);
    });

    testWidgets("persists a new event to the event repository upon submission", (WidgetTester tester) async {
      final eventRepository = InMemoryEventRepository();
      await tester.pumpWidget(ProviderScope(
        overrides: [eventProvider.overrideWithProvider(Provider((_) => eventRepository))],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      const eventTitle = "title";
      await tester.enterText(find.widgetWithText(TextFormField, "Event title"), eventTitle);
      await tester.tap(find.widgetWithText(ElevatedButton, "Submit"));
      await tester.pump();
      final events = await eventRepository.list.last;
      expect(events.first.title, equals(eventTitle));
    });
  });
}
