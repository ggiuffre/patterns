import 'package:flutter/material.dart';
import 'package:patterns/data/event.dart';
import 'package:test/test.dart';

void main() {
  group("recurringEvents", () {
    test("returns events with the given title", () {
      const title = "title";
      final events = recurringEvents(
        title: title,
        range: DateTimeRange(start: DateTime(1970, 1, 1), end: DateTime(1970, 1, 16)),
        frequency: Frequency.daily,
      );
      expect(events.every((e) => e.title == title), true);
    });

    test("returns events not before the given time range", () {
      final startDate = DateTime(1984, 2, 2);
      final events = recurringEvents(
        title: "title",
        range: DateTimeRange(start: startDate, end: DateTime(1984, 3, 4)),
        frequency: Frequency.weekly,
      );
      expect(events.any((e) => e.time.isBefore(startDate)), false);
    });

    test("returns events not after the given time range", () {
      final endDate = DateTime(1750, 12, 2);
      final events = recurringEvents(
        title: "title",
        range: DateTimeRange(start: DateTime(1748, 6, 20), end: endDate),
        frequency: Frequency.monthly,
      );
      expect(events.every((e) => endDate.isAfter(e.time)), true);
    });

    test("returns as many daily events as there are days in the range", () {
      final range = DateTimeRange(start: DateTime(1970, 2, 23), end: DateTime(1971, 7, 16));
      final events = recurringEvents(
        title: "title",
        range: range,
        frequency: Frequency.daily,
      );
      expect(events.length, equals(range.duration.inDays + 1));
    });

    test("returns a singleton if the frequency interval is greater than the range", () {
      final startDate = DateTime(2000, 1, 31);
      final range = DateTimeRange(start: startDate, end: DateTime(2000, 7, 2));
      final events = recurringEvents(
        title: "title",
        range: range,
        frequency: Frequency.annually,
      );
      expect(events, orderedEquals([Event("title", startDate)]));
    });

    test("returns events that are one day apart if given a frequency of 'daily'", () {
      final range = DateTimeRange(start: DateTime(1492, 1, 1), end: DateTime(1492, 3, 28));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.daily);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect(DateTime(event.time.year, event.time.month, event.time.day - 1), previousDate);
        previousDate = event.time;
      }
    });

    test("returns events that are 3 days apart if given a frequency of 'daily' and interval 3", () {
      final range = DateTimeRange(start: DateTime(1492, 1, 1), end: DateTime(1492, 3, 28));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.daily, interval: 3);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect(DateTime(event.time.year, event.time.month, event.time.day - 3), previousDate);
        previousDate = event.time;
      }
    });

    test("returns events that are one week apart if given a frequency of 'weekly'", () {
      final range = DateTimeRange(start: DateTime(1890, 5, 10), end: DateTime(1892, 2, 2));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.weekly);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect(DateTime(event.time.year, event.time.month, event.time.day - 7), previousDate);
        previousDate = event.time;
      }
    });

    test("returns events that are two weeks apart if given a frequency of 'weekly' and interval 2", () {
      final range = DateTimeRange(start: DateTime(2004, 11, 21), end: DateTime(2005, 11, 21));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.weekly, interval: 2);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect(DateTime(event.time.year, event.time.month, event.time.day - 14), previousDate);
        previousDate = event.time;
      }
    });

    test("returns events that are one month apart if given a frequency of 'monthly'", () {
      final range = DateTimeRange(start: DateTime(1999, 1, 31), end: DateTime(1999, 10, 2));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.monthly);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect((event.time.month - previousDate.month) % 12, equals(1));
        previousDate = event.time;
      }
    });

    test("returns events that are two months apart if given a frequency of 'monthly' and interval 2", () {
      final range = DateTimeRange(start: DateTime(1900, 2, 3), end: DateTime(1920, 9, 10));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.monthly, interval: 2);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect((event.time.month - previousDate.month) % 12, equals(2));
        previousDate = event.time;
      }
    });

    test("returns events that are each one year apart if given a frequency of 'annually'", () {
      final range = DateTimeRange(start: DateTime(1200, 11, 11), end: DateTime(1234, 5, 6));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.annually);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect(event.time.year - previousDate.year, equals(1));
        previousDate = event.time;
      }
    });

    test("returns events that are each 4 years apart if given a frequency of 'annually' and interval 4", () {
      final range = DateTimeRange(start: DateTime(1200, 11, 11), end: DateTime(1234, 5, 6));
      final events = recurringEvents(title: "title", range: range, frequency: Frequency.annually, interval: 4);
      DateTime previousDate = events.first.time;
      for (final event in events.skip(1)) {
        expect(event.time.year - previousDate.year, equals(4));
        previousDate = event.time;
      }
    });
  });
}
