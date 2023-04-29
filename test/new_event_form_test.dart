import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/repositories/events.dart';
import 'package:patterns/src/ui/components/new_event_form.dart';

main() {
  group("The new-event form", () {
    testWidgets("shows a text field to enter a title",
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.widgetWithText(TextFormField, "Event title"), findsOneWidget);
    });

    testWidgets("shows a gesture detector to enter a start time",
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.widgetWithText(GestureDetector, "Start"), findsOneWidget);
    });

    testWidgets("shows a gesture detector to enter an end time",
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.widgetWithText(GestureDetector, "End"), findsOneWidget);
    });

    testWidgets("shows a radio list to select a frequency",
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets("shows a submit button", (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final scrollableForm =
          find.descendant(of: find.byType(Form), matching: scrollable).first;
      final submitButtonFinder = find.widgetWithText(ElevatedButton, "Submit");
      await tester.scrollUntilVisible(submitButtonFinder, 100,
          scrollable: scrollableForm);
      expect(submitButtonFinder, findsOneWidget);
    });

    testWidgets("shows a progress indicator upon form submission",
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      await tester.enterText(
          find.widgetWithText(TextFormField, "Event title"), "title");
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final scrollableForm =
          find.descendant(of: find.byType(Form), matching: scrollable).first;
      final submitButtonFinder = find.widgetWithText(ElevatedButton, "Submit");
      await tester.scrollUntilVisible(submitButtonFinder, 100,
          scrollable: scrollableForm);
      await tester.tap(submitButtonFinder);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets("executes a callback upon form submission",
        (WidgetTester tester) async {
      bool formSubmitted = false;
      void onSubmit() => formSubmitted = true;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: onSubmit)),
      ));

      await tester.enterText(
          find.widgetWithText(TextFormField, "Event title"), "title");
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final scrollableForm =
          find.descendant(of: find.byType(Form), matching: scrollable).first;
      final submitButtonFinder = find.widgetWithText(ElevatedButton, "Submit");
      await tester.scrollUntilVisible(submitButtonFinder, 100,
          scrollable: scrollableForm);
      await tester.tap(submitButtonFinder);
      await tester.pump();
      expect(formSubmitted, true);
    });

    testWidgets("shows an error if the event title is empty upon submission",
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          writableEventProvider
              .overrideWith((_) => const DummyEventRepository())
        ],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final scrollableForm =
          find.descendant(of: find.byType(Form), matching: scrollable).first;
      final submitButtonFinder = find.widgetWithText(ElevatedButton, "Submit");
      await tester.scrollUntilVisible(submitButtonFinder, 100,
          scrollable: scrollableForm);
      await tester.tap(submitButtonFinder);
      await tester.pump();
      expect(
          find.text("Please enter a title for this event", skipOffstage: false),
          findsOneWidget);
    });

    testWidgets("persists a new event to the event repository upon submission",
        (WidgetTester tester) async {
      final eventRepository = InMemoryEventRepository();
      await tester.pumpWidget(ProviderScope(
        overrides: [writableEventProvider.overrideWith((_) => eventRepository)],
        child: MaterialApp(home: NewEventForm(onSubmit: () {})),
      ));

      const eventTitle = "title";
      await tester.enterText(
          find.widgetWithText(TextFormField, "Event title"), eventTitle);
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final scrollableForm =
          find.descendant(of: find.byType(Form), matching: scrollable).first;
      final submitButtonFinder = find.widgetWithText(ElevatedButton, "Submit");
      await tester.scrollUntilVisible(submitButtonFinder, 100,
          scrollable: scrollableForm);
      await tester.tap(submitButtonFinder);
      await tester.pump();
      expect(eventRepository.events.first.title, equals(eventTitle));
    });
  });
}
