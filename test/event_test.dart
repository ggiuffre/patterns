import 'package:flutter/material.dart';
import 'package:patterns/src/data/event.dart';
import 'package:test/test.dart';

import 'factories.dart';

main() {
  group("The monthsLater extension method on DateTime", () {
    test("returns a date in the future compared to the original, when adding months", () {
      final original = randomDate();
      final result = original.monthsLater(months: randomInt(max: 24) + 1);
      expect(original.isBefore(result), isTrue);
    });

    test("returns a date in the past compared to the original, when subtracting months", () {
      final original = randomDate();
      final result = original.monthsLater(months: -(randomInt(max: 24) + 1));
      expect(original.isAfter(result), isTrue);
    });

    test("returns the same date as the original, when adding 0 months", () {
      final original = randomDate();
      final result = original.monthsLater(months: 0);
      expect(original.isAtSameMomentAs(result), isTrue);
    });

    test("returns a date with the same day of the month, if the original day is below 29", () {
      final original = randomDate(day: randomInt(max: 28) + 1);
      final result = original.monthsLater(months: randomInt(max: 24));
      expect(original.day == result.day, isTrue);
    });

    test("returns April 30th, if increasing March 31st by 1 month", () {
      final original = randomDate(day: 31, month: 3);
      final result = original.monthsLater(months: 1);
      expect(result.day == 30, isTrue);
      expect(result.month == 4, isTrue);
    });

    test("returns a date in the next year, if increasing a date in December by 1 month", () {
      final original = randomDate(month: 12);
      final result = original.monthsLater(months: 1);
      expect(result.year == original.year + 1, isTrue);
    });

    test("returns a date in the same year, if increasing a date in November by 1 month", () {
      final original = randomDate(month: 1);
      final result = original.monthsLater(months: 1);
      expect(result.year == original.year, isTrue);
    });

    test("called 12 times returns a date in the next year and same month, if increasing the result by 1 month", () {
      final original = randomDate();
      DateTime result = original;
      for (int i = 0; i < 12; i += 1) {
        result = result.monthsLater(months: 1);
      }
      expect(result.year == original.year + 1, isTrue);
      expect(result.month == original.month, isTrue);
    });
  });

  group("The increaseByInterval extension method on DateTime", () {
    group("with daily frequency argument", () {
      const daily = Frequency.daily;
      test("returns a date in the future compared to the original, when adding days", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: randomInt(max: 400) + 1, frequency: daily);
        expect(original.isBefore(result), isTrue);
      });

      test("returns a date in the past compared to the original, when subtracting days", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: -(randomInt(max: 400) + 1), frequency: daily);
        expect(original.isAfter(result), isTrue);
      });

      test("returns the same date as the original, when adding 0 days", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: 0, frequency: daily);
        expect(original.isAtSameMomentAs(result), isTrue);
      });

      test("returns a date n days away from the original, when adding n days", () {
        final n = randomInt(max: 400) + 1;
        final original = randomDate();
        final result = original.increaseByInterval(interval: n, frequency: daily);
        expect(result.difference(original), Duration(days: n));
      });
    });

    group("with weekly frequency argument", () {
      const weekly = Frequency.weekly;
      test("returns a date in the future compared to the original, when adding weeks", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: randomInt(max: 75) + 1, frequency: weekly);
        expect(original.isBefore(result), isTrue);
      });

      test("returns a date in the past compared to the original, when subtracting weeks", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: -(randomInt(max: 75) + 1), frequency: weekly);
        expect(original.isAfter(result), isTrue);
      });

      test("returns the same date as the original, when adding 0 weeks", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: 0, frequency: weekly);
        expect(original.isAtSameMomentAs(result), isTrue);
      });

      test("returns a date n * 7 days away from the original, when adding n weeks", () {
        final n = randomInt(max: 75) + 1;
        final original = randomDate();
        final result = original.increaseByInterval(interval: n, frequency: weekly);
        expect(result.difference(original), Duration(days: n * 7));
      });
    });

    group("with monthly frequency argument", () {
      const monthly = Frequency.monthly;
      test("returns a date in the future compared to the original, when adding months", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: randomInt(max: 24) + 1, frequency: monthly);
        expect(original.isBefore(result), isTrue);
      });

      test("returns a date in the past compared to the original, when subtracting months", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: -(randomInt(max: 24) + 1), frequency: monthly);
        expect(original.isAfter(result), isTrue);
      });

      test("returns the same date as the original, when adding 0 months", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: 0, frequency: monthly);
        expect(original.isAtSameMomentAs(result), isTrue);
      });

      test("returns a date n % 12 months away from the original, when adding n % 12 months", () {
        final n = randomInt(max: 24) + 1;
        final original = randomDate();
        final result = original.increaseByInterval(interval: n, frequency: monthly);
        expect((result.month - original.month) % 12, n % 12);
      });
    });

    group("with yearly frequency argument", () {
      const yearly = Frequency.yearly;
      test("returns a date in the future compared to the original, when adding years", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: randomInt(max: 30) + 1, frequency: yearly);
        expect(original.isBefore(result), isTrue);
      });

      test("returns a date in the past compared to the original, when subtracting years", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: -(randomInt(max: 30) + 1), frequency: yearly);
        expect(original.isAfter(result), isTrue);
      });

      test("returns the same date as the original, when adding 0 years", () {
        final original = randomDate();
        final result = original.increaseByInterval(interval: 0, frequency: yearly);
        expect(original.isAtSameMomentAs(result), isTrue);
      });

      test("returns a date n years away from the original, when adding n years", () {
        final n = randomInt(max: 30) + 1;
        final original = randomDate();
        final result = original.increaseByInterval(interval: n, frequency: yearly);
        expect(result.year - original.year, n);
      });
    });
  });

  group("The recurringEvents function", () {
    test("returns events with the given title", () {
      const title = "title";
      final events = recurringEvents(
        title: title,
        value: 1,
        range: DateTimeRange(start: DateTime.utc(1970, 1, 1), end: DateTime.utc(1970, 1, 16)),
        frequency: Frequency.daily,
      );
      expect(events.every((e) => e.title == title), true);
    });

    test("returns events not before the given time range", () {
      final startDate = DateTime.utc(1984, 2, 2);
      final events = recurringEvents(
        title: "title",
        value: 1,
        range: DateTimeRange(start: startDate, end: DateTime.utc(1984, 3, 4)),
        frequency: Frequency.weekly,
      );
      expect(events.any((e) => e.start.isBefore(startDate)), false);
    });

    test("returns events not after the given time range", () {
      final endDate = DateTime.utc(1750, 12, 2);
      final events = recurringEvents(
        title: "title",
        value: 1,
        range: DateTimeRange(start: DateTime.utc(1748, 6, 20), end: endDate),
        frequency: Frequency.monthly,
      );
      expect(events.every((e) => endDate.isAfter(e.start)), true);
    });

    test("returns as many daily events as there are days in the range", () {
      final range = DateTimeRange(start: DateTime.utc(1970, 2, 23), end: DateTime.utc(1971, 7, 16));
      final events = recurringEvents(
        title: "title",
        value: 1,
        range: range,
        frequency: Frequency.daily,
      );
      expect(events.length, equals(range.duration.inDays + 1));
    });

    test("returns events that include the last day in the range, if given daily frequency", () {
      final range = DateTimeRange(start: DateTime.utc(1970, 2, 23), end: DateTime.utc(1971, 7, 16));
      final events = recurringEvents(
        title: "title",
        value: 1,
        range: range,
        frequency: Frequency.daily,
      );
      expect(events.last.start.day, equals(16));
      expect(events.last.start.month, equals(7));
      expect(events.last.start.year, equals(1971));
    });

    test("returns 2 events, if given daily frequency and a 2-day range", () {
      final range = DateTimeRange(start: DateTime.utc(1970, 2, 23), end: DateTime.utc(1970, 2, 24));
      final events = recurringEvents(
        title: "title",
        value: 1,
        range: range,
        frequency: Frequency.daily,
      );
      expect(events.length, equals(2));
    });

    test("returns a singleton if the frequency interval is greater than the range", () {
      final startDate = DateTime.utc(2000, 1, 31);
      final range = DateTimeRange(start: startDate, end: DateTime.utc(2000, 7, 2));
      final events = recurringEvents(
        title: "title",
        value: 1,
        range: range,
        frequency: Frequency.yearly,
      );
      expect(events, orderedEquals([Event("title", value: 1, start: startDate)]));
    });

    test("returns events that are one day apart if given a frequency of 'daily'", () {
      final range = DateTimeRange(start: DateTime.utc(1492, 1, 1), end: DateTime.utc(1492, 3, 28));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.daily);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect(DateTime.utc(event.start.year, event.start.month, event.start.day - 1), previousDate);
        previousDate = event.start;
      }
    });

    test("returns events that are 3 days apart if given a frequency of 'daily' and interval 3", () {
      final range = DateTimeRange(start: DateTime.utc(1492, 1, 1), end: DateTime.utc(1492, 3, 28));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.daily, interval: 3);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect(DateTime.utc(event.start.year, event.start.month, event.start.day - 3), previousDate);
        previousDate = event.start;
      }
    });

    test("returns events that are one week apart if given a frequency of 'weekly'", () {
      final range = DateTimeRange(start: DateTime.utc(1890, 5, 10), end: DateTime.utc(1892, 2, 2));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.weekly);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect(DateTime.utc(event.start.year, event.start.month, event.start.day - 7), previousDate);
        previousDate = event.start;
      }
    });

    test("returns events that are two weeks apart if given a frequency of 'weekly' and interval 2", () {
      final range = DateTimeRange(start: DateTime.utc(2004, 11, 21), end: DateTime.utc(2005, 11, 21));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.weekly, interval: 2);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect(DateTime.utc(event.start.year, event.start.month, event.start.day - 14), previousDate);
        previousDate = event.start;
      }
    });

    test("returns events that are one month apart if given a frequency of 'monthly'", () {
      final range = DateTimeRange(start: DateTime.utc(1999, 1, 31), end: DateTime.utc(1999, 10, 2));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.monthly);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect((event.start.month - previousDate.month) % 12, equals(1));
        previousDate = event.start;
      }
    });

    test("returns events that are two months apart if given a frequency of 'monthly' and interval 2", () {
      final range = DateTimeRange(start: DateTime.utc(1900, 2, 3), end: DateTime.utc(1920, 9, 10));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.monthly, interval: 2);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect((event.start.month - previousDate.month) % 12, equals(2));
        previousDate = event.start;
      }
    });

    test("returns events that are each one year apart if given a frequency of 'yearly'", () {
      final range = DateTimeRange(start: DateTime.utc(1200, 11, 11), end: DateTime.utc(1234, 5, 6));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.yearly);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect(event.start.year - previousDate.year, equals(1));
        previousDate = event.start;
      }
    });

    test("returns events that are each 4 years apart if given a frequency of 'yearly' and interval 4", () {
      final range = DateTimeRange(start: DateTime.utc(1200, 11, 11), end: DateTime.utc(1234, 5, 6));
      final events = recurringEvents(title: "title", value: 1, range: range, frequency: Frequency.yearly, interval: 4);
      DateTime previousDate = events.first.start;
      for (final event in events.skip(1)) {
        expect(event.start.year - previousDate.year, equals(4));
        previousDate = event.start;
      }
    });
  });
}
