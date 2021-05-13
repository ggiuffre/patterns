import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/ui/components/new_event_form.dart';

main() {
  testWidgets("The new-event form shows a text field to enter a title", (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: NewEventForm(onSubmit: () {}))));

    expect(find.widgetWithText(TextFormField, "Event title"), findsOneWidget);
  });

  testWidgets("The new-event form shows a text field to enter a time", (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: NewEventForm(onSubmit: () {}))));

    expect(find.widgetWithText(TextFormField, "Event time"), findsOneWidget);
  });

  testWidgets("The new-event form shows a radio list to select a frequency", (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: NewEventForm(onSubmit: () {}))));

    expect(find.byType(ExpansionTile), findsOneWidget);
  });

  testWidgets("The new-event form shows a submit button", (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: NewEventForm(onSubmit: () {}))));

    expect(find.widgetWithText(ElevatedButton, "Submit"), findsOneWidget);
  });
}
