import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event implements Comparable<Event> {
  final String id;
  final String title;
  final DateTime time;

  const Event(this.title, this.time) : id = "$time$title";

  Event.fromFirestore(this.title, Timestamp timestamp, this.id) : time = timestamp.toDate();

  Event.fromJson(Map<String, Object> json)
      : id = json["id"] as String,
        title = json["title"] as String,
        time = json["time"] as DateTime;

  Map<String, String> get asJson => {"id": id, "title": title, "time": time.toIso8601String()};

  @override
  int compareTo(Event other) => time == other.time ? title.compareTo(other.title) : time.compareTo(other.time);

  @override
  bool operator ==(Object other) => other is Event && time == other.time && title == other.title;

  @override
  int get hashCode => hashValues(title, time);

  bool operator <(Event other) => compareTo(other) < 0;

  bool operator <=(Event other) => compareTo(other) <= 0;

  bool operator >=(Event other) => compareTo(other) >= 0;

  bool operator >(Event other) => compareTo(other) > 0;
}

/// Frequency at which an [Event] can occur.
enum Frequency { once, daily, weekly, monthly, annually }

/// Get a sequence of events named [title] with time inside [range], recurring
/// on a [frequency] basis at intervals of [interval].
Iterable<Event> recurringEvents({
  required String title,
  required DateTimeRange range,
  required Frequency frequency,
  int interval = 1,
}) {
  if (frequency == Frequency.once) {
    return {Event(title, range.start)};
  }

  final actions = <Frequency, DateTime Function(DateTime, int)>{
    Frequency.daily: (DateTime t, int interval) =>
        DateTime(t.year, t.month, t.day + interval, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.weekly: (DateTime t, int interval) =>
        DateTime(t.year, t.month, t.day + (7 * interval), t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.monthly: (DateTime t, int interval) => monthsLater(t: t, months: interval),
    Frequency.annually: (DateTime t, int interval) =>
        DateTime(t.year + interval, t.month, t.day, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
  };

  List<Event> result = [];
  DateTime time = range.start;
  while (time.isBefore(range.end)) {
    result.add(Event(title, time));
    time = actions[frequency]!(time, interval);
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

String recurringEventStringDescription({required Frequency frequency, required int interval}) {
  if (frequency == Frequency.once) {
    return "Does not repeat";
  } else if (frequency == Frequency.daily) {
    if (interval < 2) {
      return "Occurs daily";
    } else if (interval == 2) {
      return "Occurs every other day";
    } else {
      return "Occurs every $interval days";
    }
  } else if (frequency == Frequency.weekly) {
    if (interval < 2) {
      return "Occurs weekly";
    } else if (interval == 2) {
      return "Occurs every other week";
    } else {
      return "Occurs every $interval weeks";
    }
  } else if (frequency == Frequency.monthly) {
    if (interval < 2) {
      return "Occurs monthly";
    } else if (interval == 2) {
      return "Occurs every other month";
    } else {
      return "Occurs every $interval months";
    }
  } else if (frequency == Frequency.annually) {
    if (interval < 2) {
      return "Occurs yearly";
    } else if (interval == 2) {
      return "Occurs every other year";
    } else {
      return "Occurs every $interval years";
    }
  } else {
    return "Does not repeat";
  }
}
