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

    test("of a singleton has 1 entry", () {
      final events = [randomEvent()];
      final result = termFrequencies(events);
      expect(result.length, 1);
    });

    test("of a singleton with a one-word title has 1 value with 1 entry", () {
      final events = [randomEvent(title: "test")];
      final result = termFrequencies(events);
      expect(result.values.first.length, 1);
    });

    test("of a singleton with a known title has 1 entry at a known key", () {
      final event = randomEvent();
      final events = [event];
      final result = termFrequencies(events);
      expect(result[event.title], isNotNull);
    });

    test(
        "of a singleton with a one-word title has 1 value with 1 entry at a known key",
        () {
      const title = "test";
      final events = [randomEvent(title: title)];
      final result = termFrequencies(events);
      expect(result[title]?[title], isNotNull);
    });

    test("of a singleton whose title is the repetition of 1 word has 1 entry",
        () {
      final title = List.generate(randomInt(), (index) => "test").join(' ');
      final events = [randomEvent(title: title)];
      final result = termFrequencies(events);
      expect(result.length, 1);
    });

    test("of 2 events with the same title has 1 entry", () {
      const title = "test hello";
      final events = [randomEvent(title: title), randomEvent(title: title)];
      final result = termFrequencies(events);
      expect(result.length, 1);
    });

    test("of 2 events with distinct titles has 2 entry", () {
      final events = [
        randomEvent(title: "hello abc"),
        randomEvent(title: "test"),
      ];
      final result = termFrequencies(events);
      expect(result.length, 2);
    });

    test("of of Florida Man headlines have known scores", () {
      const titles = [
        "Florida man Breaks into Joes Crab Shack, Steals Alcohol, Leaves Poop as payment",
        "Florida Man Pretending to Be Cop Pulls over Actual Cop",
        "Florida Man Gets Trapped in Porta-potty, Busted for Drugs",
        "Florida Man Driving Car Full of Stolen Mail Crashes into Trailer Full of Alpacas",
      ];
      final events = titles.map((title) => randomEvent(title: title));
      final result = termFrequencies(events);
      expect(
          result,
          equals({
            "florida man breaks into joes crab shack, steals alcohol, leaves poop as payment":
                {
              "florida": 1 / 13,
              "man": 1 / 13,
              "breaks": 1 / 13,
              "into": 1 / 13,
              "joes": 1 / 13,
              "crab": 1 / 13,
              "shack": 1 / 13,
              "steals": 1 / 13,
              "alcohol": 1 / 13,
              "leaves": 1 / 13,
              "poop": 1 / 13,
              "as": 1 / 13,
              "payment": 1 / 13,
            },
            "florida man pretending to be cop pulls over actual cop": {
              "florida": 1 / 10,
              "man": 1 / 10,
              "pretending": 1 / 10,
              "to": 1 / 10,
              "be": 1 / 10,
              "cop": 2 / 10,
              "pulls": 1 / 10,
              "over": 1 / 10,
              "actual": 1 / 10,
            },
            "florida man gets trapped in porta-potty, busted for drugs": {
              "florida": 1 / 10,
              "man": 1 / 10,
              "gets": 1 / 10,
              "trapped": 1 / 10,
              "in": 1 / 10,
              "porta": 1 / 10,
              "potty": 1 / 10,
              "busted": 1 / 10,
              "for": 1 / 10,
              "drugs": 1 / 10,
            },
            "florida man driving car full of stolen mail crashes into trailer full of alpacas":
                {
              "florida": 1 / 14,
              "man": 1 / 14,
              "driving": 1 / 14,
              "car": 1 / 14,
              "full": 2 / 14,
              "of": 2 / 14,
              "stolen": 1 / 14,
              "mail": 1 / 14,
              "crashes": 1 / 14,
              "into": 1 / 14,
              "trailer": 1 / 14,
              "alpacas": 1 / 14,
            },
          }));
    });
  });

  group("document frequencies", () {
    test("of an empty list of events are an empty map", () {
      const events = <Event>[];
      final result = inverseDocumentFrequencies(events);
      expect(result, isEmpty);
    });
  });
}
