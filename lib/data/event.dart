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

  Event.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        time = json["time"];

  Map<String, dynamic> get asJson => {"id": id, "title": title, "time": time};

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
enum Frequency { daily, weekly, biWeekly, monthly, biMonthly, annually }

/// Get a sequence of events named [title] with time inside [range], recurring at [frequency].
Iterable<Event> eventsAtInterval({required String title, required DateTimeRange range, required Frequency frequency}) {
  final actions = <Frequency, DateTime Function(DateTime)>{
    Frequency.daily: (DateTime t) => t.add(const Duration(days: 1)),
    Frequency.weekly: (DateTime t) => t.add(const Duration(days: 7)),
    Frequency.biWeekly: (DateTime t) => t.add(const Duration(days: 14)),
    Frequency.monthly: (DateTime t) => DateTime(
        t.year + (t.month == 12 ? 1 : 0), t.month + 1, t.day, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.biMonthly: (DateTime t) => DateTime(
        t.year + (t.month >= 11 ? 1 : 0), t.month + 2, t.day, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
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
