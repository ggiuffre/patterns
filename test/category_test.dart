import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/category.dart';
import 'package:patterns/src/data/event.dart';

import 'factories.dart';

main() {
  group("The categoriesFromEvents function", () {
    test("returns an empty iterable, if given an empty iterable", () {
      const events = Iterable<Event>.empty();
      final categories = categoriesFromEvents(events);
      expect(categories, isEmpty);
    });

    test("returns a singleton, if given events with the same title", () {
      final events = randomEvents(15, title: randomEventTitle());
      final categories = categoriesFromEvents(events);
      expect(categories.length, 1);
    });

    test("returns as many categories as distinct event titles", () {
      final events = <Event>[];
      events.addAll(randomEvents(15, title: "a"));
      events.addAll(randomEvents(10, title: "b"));
      events.addAll(randomEvents(12, title: "c"));
      final categories = categoriesFromEvents(events);
      expect(categories.length, 3);
    });
  });
}
