import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/src/data/event.dart';
import 'package:patterns/src/data/similarities.dart';

import 'factories.dart';

void main() {
  group("similarities", () {
    test(
        "returns as (n * (n - 1)) / 2 elements where n is the number of 'categories' it computes on",
        () {
      final events = randomEvents(20, fromYear: 2005, toYear: 2007);
      final categories = events.map((e) => e.title).toSet();
      final result = similarities(events);
      expect(result.length,
          equals((categories.length * (categories.length - 1) / 2)));
    });
  });

  group("similarity", () {
    test("is at least -1", () {
      final series1 =
          randomEvents(10, title: "title", fromYear: 2005, toYear: 2007);
      final series2 =
          randomEvents(20, title: "title", fromYear: 2005, toYear: 2007);
      final result = similarity(series1, series2);
      expect(result, greaterThanOrEqualTo(-1));
    });

    test("is at most 1", () {
      final series1 =
          randomEvents(50, title: "title", fromYear: 2005, toYear: 2007);
      final series2 =
          randomEvents(30, title: "title", fromYear: 2005, toYear: 2007);
      final result = similarity(series1, series2);
      expect(result, lessThanOrEqualTo(1.0));
    });

    test("of identical series is 1", () {
      final series =
          randomEvents(30, title: "title", fromYear: 2005, toYear: 2007);
      final result = similarity(series, series);
      expect((result - 1).abs(), lessThan(1e-15));
    });

    test("of 'complementary' binary series is -1", () {
      final series1 = [
        Event("title", value: 0, start: DateTime.utc(1994, 2, 20)),
        Event("title", value: 1, start: DateTime.utc(1994, 2, 21)),
        Event("title", value: 0, start: DateTime.utc(1994, 2, 22)),
        Event("title", value: 1, start: DateTime.utc(1994, 2, 23)),
      ];
      final series2 = [
        Event("title", value: 1, start: DateTime.utc(1994, 2, 20)),
        Event("title", value: 0, start: DateTime.utc(1994, 2, 21)),
        Event("title", value: 1, start: DateTime.utc(1994, 2, 22)),
        Event("title", value: 0, start: DateTime.utc(1994, 2, 23)),
      ];
      final result = similarity(series1, series2);
      expect(result, equals(-1));
    });

    test("of series with different length can be calculated", () {
      final series1 = randomEvents(randomInt(max: 50) + 2,
          title: "title", fromYear: 2005, toYear: 2007);
      final series2 = randomEvents(randomInt(max: 50) + 2,
          title: "title", fromYear: 2005, toYear: 2007);
      final result = similarity(series1, series2);
      expect(result, isA<double>());
    });

    test(
        "of identical series is greater than similarity of same pair with one unit displaced",
        () {
      final series1 =
          randomEvents(30, title: "title", fromYear: 2005, toYear: 2007);
      final series2 = [
        ...series1.sublist(0, series1.length - 1),
        Event("title",
            value: randomDouble(),
            start: series1.last.start.add(const Duration(days: 1)))
      ];
      expect(similarity(series1, series1),
          greaterThan(similarity(series1, series2)));
    });

    test("is commutative in its arguments", () {
      final series1 = randomEvents(randomInt(max: 50) + 2,
          title: "title", fromYear: 2005, toYear: 2007);
      final series2 = randomEvents(randomInt(max: 50) + 2,
          title: "title", fromYear: 2005, toYear: 2007);
      expect(
          similarity(series1, series2), equals(similarity(series2, series1)));
    });
  });

  group("interpolated", () {
    test("returns a list containing all the events that it was passed", () {
      final events = randomEvents(randomInt(max: 50) + 2,
          title: "title", fromYear: 2005, toYear: 2007);
      expect(interpolated(events), containsAll(events));
    });

    test("returns events with date in given range, if given only two events",
        () {
      final event1 = Event("title",
          value: randomDouble(), start: DateTime.utc(1999, 3, 2));
      final event2 = Event("title",
          value: randomDouble(), start: DateTime.utc(1999, 6, 7));
      final result = interpolated([event1, event2]);
      expect(result.every((element) => !event1.start.isAfter(element.start)),
          isTrue);
      expect(result.every((element) => !element.start.isAfter(event2.start)),
          isTrue);
    });

    test("returns events with value in given range, if given only two events",
        () {
      final event1 = Event("title",
          value: randomDouble(max: 10), start: DateTime.utc(1999, 3, 2));
      final event2 = Event("title",
          value: randomDouble() + 10, start: DateTime.utc(1999, 6, 7));
      final result = interpolated([event1, event2]);
      expect(result.every((element) => event1.value <= element.value), isTrue);
      expect(result.every((element) => element.value <= event2.value), isTrue);
    });

    test(
        "returns as many events as the number of days between the oldest and newest events",
        () {
      final events = randomEvents(randomInt(max: 50) + 2,
          title: "title", fromYear: 2005, toYear: 2007);
      final result = interpolated(events);
      final range = events.last.start.difference(events.first.start).inDays;
      expect(result.length, equals(range + 1));
    });

    test("adds events with value 0, if passed binary=true", () {
      final events = randomEvents(randomInt(max: 50) + 2,
          title: "title", fromYear: 2005, toYear: 2007);
      expect(
          interpolated(events, binary: true)
              .where((e) => !events.contains(e))
              .every((e) => e.value == 0),
          isTrue);
    });
  });

  group("correlation", () {
    test("is at least -1", () {
      final nValues = randomInt(max: 50) + 2;
      final series1 =
          Iterable.generate(nValues, (_) => randomDouble(max: 100)).toSet();
      final series2 =
          Iterable.generate(nValues, (_) => randomDouble(max: 100)).toSet();
      expect(correlation(series1, series2), greaterThanOrEqualTo(-1));
    });

    test("is at most 1", () {
      final nValues = randomInt(max: 50) + 2;
      final series1 =
          Iterable.generate(nValues, (_) => randomDouble(max: 100)).toSet();
      final series2 =
          Iterable.generate(nValues, (_) => randomDouble(max: 100)).toSet();
      expect(correlation(series1, series2), lessThanOrEqualTo(1));
    });

    test("of 'complementary' binary series is -1", () {
      final series1 = [1.0, 0.0, 1.0, 0.0];
      final series2 = [0.0, 1.0, 0.0, 1.0];
      expect(correlation(series1, series2), equals(-1));
    });

    test("is commutative in its arguments", () {
      final nValues = randomInt(max: 50) + 2;
      final series1 =
          Iterable.generate(nValues, (_) => randomDouble(max: 100)).toSet();
      final series2 =
          Iterable.generate(nValues, (_) => randomDouble(max: 100)).toSet();
      expect(
          correlation(series1, series2), equals(correlation(series2, series1)));
    });

    test("of X with itself is 1", () {
      final x = Iterable.generate(
          randomInt(max: 50) + 2, (_) => randomDouble(max: 100)).toSet();
      expect((1 - correlation(x, x)), lessThan(1e-15));
    });

    test("respects cor(X + c) == cor(X)", () {
      final x = Iterable.generate(
          randomInt(max: 50) + 2, (_) => randomDouble(max: 100)).toSet();
      final c = randomDouble() * randomInt(max: 100);
      final xPlusC = x.map((v) => v + c);
      expect((correlation(x, xPlusC) - 1).abs(), lessThan(1e-14));
    });

    test("respects cor(aX) == cor(X)", () {
      final x = Iterable.generate(
          randomInt(max: 50) + 2, (_) => randomDouble(max: 100)).toSet();
      final a = randomDouble() * randomInt(max: 100);
      final aX = x.map((v) => a * v);
      expect((correlation(x, aX) - 1).abs(), lessThan(1e-14));
    });
  });
}
