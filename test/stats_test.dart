import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/event.dart';
import 'package:patterns/src/data/stats.dart';

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
      final title = List.generate(randomInt(), (_) => "test").join(' ');
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

    test("of Florida Man headlines have known scores", () {
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

    test("of a singleton with a one-word title has 1 entry", () {
      final events = [randomEvent(title: "test")];
      final result = inverseDocumentFrequencies(events);
      expect(result.length, 1);
    });

    test("of a singleton whose title is the repetition of 1 word has 1 entry",
        () {
      final title = List.generate(randomInt(), (index) => "test").join(' ');
      final events = [randomEvent(title: title)];
      final result = inverseDocumentFrequencies(events);
      expect(result.length, 1);
    });

    test("of a singleton has as many entries as distinct words in title", () {
      final title =
          List.generate(randomInt(), (_) => randomEventTitle()).join(' ');
      final distinctWordsCount = title.split(' ').toSet().length;
      final events = [randomEvent(title: title)];
      final result = inverseDocumentFrequencies(events);
      expect(result.length, distinctWordsCount);
    });

    test("of Florida Man headlines have known scores", () {
      const titles = [
        "Florida man Breaks into Joes Crab Shack, Steals Alcohol, Leaves Poop as payment",
        "Florida Man Pretending to Be Cop Pulls over Actual Cop",
        "Florida Man Gets Trapped in Porta-potty, Busted for Drugs",
        "Florida Man Driving Car Full of Stolen Mail Crashes into Trailer Full of Alpacas",
      ];
      final events = titles.map((title) => randomEvent(title: title));
      final result = inverseDocumentFrequencies(events);
      expect(
          result,
          equals({
            "florida": 0,
            "man": 0,
            "breaks": log(4),
            "into": log(2),
            "joes": log(4),
            "crab": log(4),
            "shack": log(4),
            "steals": log(4),
            "alcohol": log(4),
            "leaves": log(4),
            "poop": log(4),
            "as": log(4),
            "payment": log(4),
            "pretending": log(4),
            "to": log(4),
            "be": log(4),
            "cop": log(4),
            "pulls": log(4),
            "over": log(4),
            "actual": log(4),
            "gets": log(4),
            "trapped": log(4),
            "in": log(4),
            "porta": log(4),
            "potty": log(4),
            "busted": log(4),
            "for": log(4),
            "drugs": log(4),
            "driving": log(4),
            "car": log(4),
            "full": log(4),
            "of": log(4),
            "stolen": log(4),
            "mail": log(4),
            "crashes": log(4),
            "trailer": log(4),
            "alpacas": log(4),
          }));
    });
  });

  group("TF-IDF", () {
    test("can extract tags from simple expressions", () {
      const tf = {
        "the quick brown fox": {
          "the": 1 / 4,
          "quick": 1 / 4,
          "brown": 1 / 4,
          "fox": 1 / 4,
        },
        "the lazy dog": {
          "the": 1 / 3,
          "lazy": 1 / 3,
          "dog": 1 / 3,
        },
        "the office of the president of the united states of america": {
          "the": 3 / 11,
          "office": 1 / 11,
          "of": 3 / 11,
          "president": 1 / 11,
          "united": 1 / 11,
          "states": 1 / 11,
          "america": 1 / 11,
        },
        "brown fox jumps over lazy dog": {
          "brown": 1 / 6,
          "fox": 1 / 6,
          "jumps": 1 / 6,
          "over": 1 / 6,
          "lazy": 1 / 6,
          "dog": 1 / 6,
        },
      };
      final idf = {
        "the": log(4 / 3),
        "quick": log(4),
        "brown": log(2),
        "fox": log(2),
        "lazy": log(2),
        "dog": log(2),
        "office": log(4),
        "of": log(4),
        "president": log(4),
        "united": log(4),
        "states": log(4),
        "america": log(4),
        "jumps": log(4),
        "over": log(4),
      };
      final tfidf = tf.map((eventTitle, value) => MapEntry(
            eventTitle,
            value.map((word, v) => MapEntry(word, v * (idf[word] ?? 0.0))),
          ));
      // final expectedTfIdf = {
      //   "the quick brown fox": {
      //     "the": log(4 / 3) / 4, // 0.072
      //     "quick": log(4) / 4, // 0.346
      //     "brown": log(2) / 4, // 0.173
      //     "fox": log(2) / 4, // 0.173
      //   },
      //   "the lazy dog": {
      //     "the": log(4 / 3) / 3, // 0.095
      //     "lazy": log(2) / 3, // 0.231
      //     "dog": log(2) / 3, // 0.231
      //   },
      //   "the office of the president of the united states of america": {
      //     "the": log(4 / 3) / 11, // 0.026
      //     "office": log(4) / 11, // 0.126
      //     "of": 3 * log(4) / 11, // 0.378
      //     "president": log(4) / 11, // 0.126
      //     "united": log(4) / 11, // 0.126
      //     "states": log(4) / 11, // 0.126
      //     "america": log(4) / 11, // 0.126
      //   },
      //   "brown fox jumps over lazy dog": {
      //     "brown": log(2) / 6, // 0.115
      //     "fox": log(2) / 6, // 0.115
      //     "jumps": log(4) / 6, // 0.231
      //     "over": log(4) / 6, // 0.231
      //     "lazy": log(2) / 6, // 0.115
      //     "dog": log(2) / 6, // 0.115
      //   },
      // };
      final eventTags = tfidf.map((key, value) => MapEntry(
          key,
          value.entries
              .reduce((current, element) =>
                  element.value > current.value ? element : current)
              .key));
      expect(
          eventTags,
          equals({
            "the quick brown fox": "quick",
            "the lazy dog": "lazy",
            "the office of the president of the united states of america": "of",
            "brown fox jumps over lazy dog": "jumps",
          }));
    });
  });
}
