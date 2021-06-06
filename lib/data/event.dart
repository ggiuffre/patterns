import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event implements Comparable {
  final String id;
  final String title;
  final DateTime time;

  Event(this.title, DateTime time)
      : time = DateTime(time.year, time.month, time.day),
        id = "$time$title";

  Event.fromFirestore(this.title, Timestamp timestamp, this.id) : time = timestamp.toDate();

  Event.fromJson(Map<String, Object> json)
      : id = json["id"] as String,
        title = json["title"] as String,
        time = json["time"] as DateTime;

  Map<String, Object> get asJson => {"id": id, "title": title, "time": time};

  @override
  int compareTo(other) => time == other.time ? title.compareTo(other.title) : time.compareTo(other.time);

  @override
  bool operator ==(Object other) => other is Event && time == other.time && title == other.title;

  @override
  int get hashCode => hashValues(title, time);

  bool operator <(Object other) => compareTo(other) < 0;

  bool operator <=(Object other) => compareTo(other) <= 0;

  bool operator >=(Object other) => compareTo(other) >= 0;

  bool operator >(Object other) => compareTo(other) > 0;
}

/// Frequency at which an [Event] can occur.
enum Frequency { once, daily, weekly, biWeekly, monthly, biMonthly, annually }

/// Get a sequence of events named [title] with time inside [range], recurring at [frequency].
Iterable<Event> eventsAtInterval({required String title, required DateTimeRange range, required Frequency frequency}) {
  if (frequency == Frequency.once) {
    return {Event(title, range.start)};
  }

  final actions = <Frequency, DateTime Function(DateTime)>{
    Frequency.daily: (DateTime t) =>
        DateTime(t.year, t.month, t.day + 1, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.weekly: (DateTime t) =>
        DateTime(t.year, t.month, t.day + 7, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.biWeekly: (DateTime t) =>
        DateTime(t.year, t.month, t.day + 14, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.monthly: (DateTime t) => monthsLater(t: t, months: 1),
    Frequency.biMonthly: (DateTime t) => monthsLater(t: t, months: 2),
    Frequency.annually: (DateTime t) =>
        DateTime(t.year + 1, t.month, t.day, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
  };

  List<Event> result = [];
  DateTime time = range.start;
  while (time.isBefore(range.end)) {
    result.add(Event(title, time));
    time = actions[frequency]!(time);
  }

  return result;
}

DateTime monthsLater({required DateTime t, required int months}) {
  DateTime candidate = DateTime(t.year + (t.month + months >= 12 ? 1 : 0), t.month + months, t.day, t.hour, t.minute,
      t.second, t.millisecond, t.microsecond);

  if ((candidate.month - t.month) % 12 > months) {
    int correction = 1;
    while (((candidate.month - t.month) % 12 > months)) {
      candidate = DateTime(t.year + (t.month + months >= 12 ? 1 : 0), t.month + months, t.day - correction, t.hour,
          t.minute, t.second, t.millisecond, t.microsecond);
      correction++;
    }
  }

  return candidate;
}
