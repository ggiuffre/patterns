import 'dart:math';

import 'package:patterns/src/data/event.dart';
import 'package:patterns/src/data/similarities.dart';
import 'package:test/test.dart';

import 'factories.dart';

void main() {
  final randomGenerator = Random();

  group("similarity", () {
    test("is at least -1", () {
      final series1 = List.generate(100, (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final series2 = List.generate(30, (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final result = similarity(series1, series2);
      expect(result, greaterThanOrEqualTo(-1.0));
    });

    test("is at most 1", () {
      final series1 = List.generate(100, (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final series2 = List.generate(30, (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final result = similarity(series1, series2);
      expect(result, lessThanOrEqualTo(1.0));
    });

    test("of identical series is 1", () {
      final series = List.generate(30, (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final result = similarity(series, series);
      expect(result, equals(1.0));
    });

    test("of non-overlapping series is -1", () {
      final series =
          List.generate(30, (_) => Event("title", value: randomEventValue(), start: randomDate())).toSet().toList();
      final result = similarity(series.sublist(0, series.length ~/ 2), series.sublist(series.length ~/ 2));
      expect(result, equals(-1.0));
    });

    test("of series with different length can be calculated", () {
      final series1 = List.generate(
          randomGenerator.nextInt(50), (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final series2 = List.generate(
          randomGenerator.nextInt(50), (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final result = similarity(series1, series2);
      expect(result, isA<double>());
    });

    test("of identical series is greater than similarity of same pair with one unit displaced", () {
      final series1 = List.generate(30, (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final series2 = [
        ...series1.sublist(0, 29),
        Event("title", value: randomEventValue(), start: series1.last.start.add(const Duration(days: 1)))
      ];
      expect(similarity(series1, series1), greaterThan(similarity(series1, series2)));
    });

    test("is commutative in the two arguments that it takes", () {
      final series1 = List.generate(
          randomGenerator.nextInt(50), (_) => Event("title", value: randomEventValue(), start: randomDate()));
      final series2 = List.generate(
          randomGenerator.nextInt(50), (_) => Event("title", value: randomEventValue(), start: randomDate()));
      expect(similarity(series1, series2), equals(similarity(series2, series1)));
    });
  });

  group("interpolated", () {
    test("returns a list containing all the events that it was passed", () {
      final events = List.generate(randomGenerator.nextInt(50),
          (_) => Event("title", value: randomEventValue(), start: randomDate(sinceYear: DateTime.now().year - 1)));
      expect(interpolated(events), containsAll(events));
    });

    test("returns events with date in given range, if given only two events", () {
      final event1 = Event("title", value: randomEventValue(), start: DateTime.utc(1999, 3, 2));
      final event2 = Event("title", value: randomEventValue(), start: DateTime.utc(1999, 6, 7));
      final result = interpolated([event1, event2]);
      expect(result.every((element) => !event1.start.isAfter(element.start)), isTrue);
      expect(result.every((element) => !element.start.isAfter(event2.start)), isTrue);
    });

    test("returns events with value in given range, if given only two events", () {
      final event1 = Event("title", value: randomEventValue(max: 10), start: DateTime.utc(1999, 3, 2));
      final event2 = Event("title", value: randomEventValue() + 10, start: DateTime.utc(1999, 6, 7));
      final result = interpolated([event1, event2]);
      expect(result.every((element) => event1.value <= element.value), isTrue);
      expect(result.every((element) => element.value <= event2.value), isTrue);
    });

    test("returns as many events as the number of days between the oldest and newest events", () {
      final events = List.generate(randomGenerator.nextInt(50),
              (_) => Event("title", value: randomEventValue(), start: randomDate(sinceYear: DateTime.now().year)))
          .toSet()
          .toList();
      final result = interpolated(events);
      final range = events.last.start.difference(events.first.start).inDays;
      expect(result.length, equals(range + 1));
    });
  });
}
