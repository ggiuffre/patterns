import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/event.dart';
import 'package:patterns/src/data/repositories/stats.dart';

import 'factories.dart';

void main() {
  group("term frequencies", () {
    test("of an empty list of events are an empty map", () {
      const events = <Event>[];
      final result = termFrequencies(events);
      expect(result, isEmpty);
    });

    test("of a singleton with a one-word title has 1 value", () {
      final events = [randomEvent(title: "test")];
      final result = termFrequencies(events);
      expect(result.length, 1);
    });

    test("of a singleton whose title is the repetition of 1 word has 1 value",
        () {
      final title = List.generate(randomInt(), (index) => "test").join(' ');
      final events = [randomEvent(title: title)];
      final result = termFrequencies(events);
      expect(result.length, 1);
    });
  });

  group("document frequencies", () {
    test("of an empty list of events are an empty map", () {
      const events = <Event>[];
      final result = documentFrequencies(events);
      expect(result, isEmpty);
    });
  });
}
