import 'package:flutter/material.dart';
import 'package:patterns/data/event.dart';
import 'package:test/test.dart';

void main() {
  test("eventsAtInterval returns events with the given title", () {
    const title = "title";
    final events = eventsAtInterval(
      title: title,
      range: DateTimeRange(start: DateTime(1970, 1, 1), end: DateTime(1970, 1, 16)),
      frequency: Frequency.daily,
    );
    expect(events.every((e) => e.title == title), true);
  });

  test("eventsAtInterval returns events not before the given time range", () {
    final startDate = DateTime(1984, 2, 2);
    final events = eventsAtInterval(
      title: "title",
      range: DateTimeRange(start: startDate, end: DateTime(1984, 3, 4)),
      frequency: Frequency.weekly,
    );
    expect(events.any((e) => e.time.isBefore(startDate)), false);
  });

  test("eventsAtInterval returns events not after the given time range", () {
    final endDate = DateTime(1750, 12, 2);
    final events = eventsAtInterval(
      title: "title",
      range: DateTimeRange(start: DateTime(1748, 6, 20), end: endDate),
      frequency: Frequency.monthly,
    );
    expect(events.every((e) => endDate.isAfter(e.time)), true);
  });

  test("eventsAtInterval returns as many daily events as there are days in the range", () {
    final range = DateTimeRange(start: DateTime(1970, 2, 23), end: DateTime(1971, 7, 16));
    final events = eventsAtInterval(
      title: "title",
      range: range,
      frequency: Frequency.daily,
    );
    expect(events.length, equals(range.duration.inDays));
  });

  test("eventsAtInterval returns a singleton if the frequency interval is greater than the range", () {
    final startDate = DateTime(2000, 1, 31);
    final range = DateTimeRange(start: startDate, end: DateTime(2000, 7, 2));
    final events = eventsAtInterval(
      title: "title",
      range: range,
      frequency: Frequency.annually,
    );
    expect(events, orderedEquals([Event("title", startDate)]));
  });

  test("eventsAtInterval returns events that are one day apart, if given a frequency of 'daily'", () {
    final range = DateTimeRange(start: DateTime(1492, 1, 1), end: DateTime(1492, 3, 28));
    final events = eventsAtInterval(
      title: "title",
      range: range,
      frequency: Frequency.daily,
    );
    const interval = Duration(days: 1);
    DateTime previousDate = range.start.subtract(interval);
    for (final event in events) {
      expect(event.time.subtract(interval), previousDate);
      previousDate = event.time;
    }
  });

  test("eventsAtInterval returns events that are one week apart, if given a frequency of 'weekly'", () {
    final range = DateTimeRange(start: DateTime(1890, 5, 10), end: DateTime(1892, 2, 2));
    final events = eventsAtInterval(
      title: "title",
      range: range,
      frequency: Frequency.weekly,
    );
    const interval = Duration(days: 7);
    DateTime previousDate = range.start.subtract(interval);
    for (final event in events) {
      expect(event.time.subtract(interval), previousDate);
      previousDate = event.time;
    }
  });
}
