import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show DateTimeRange;

class Event implements Comparable<Event> {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final Map<String, String?> recurrence;

  static const defaultRecurrence = <String, String?>{"rRule": null, "exRule": null, "rDate": null, "exDate": null};

  const Event(this.title, {required this.start, this.end, this.recurrence = defaultRecurrence}) : id = "$start$title";

  Event.fromFirestore(
    this.title, {
    required Timestamp start,
    Timestamp? end,
    required this.id,
    this.recurrence = defaultRecurrence,
  })  : start = start.toDate(),
        end = end?.toDate();

  Map<String, String> get asJson => {
        "id": id,
        "title": title,
        "start": start.toIso8601String(),
        "end": end?.toIso8601String() ?? "",
        "recurrence": recurrence.toString(),
      };

  @override
  int compareTo(Event other) => start == other.start ? title.compareTo(other.title) : start.compareTo(other.start);

  @override
  bool operator ==(Object other) => other is Event && start == other.start && title == other.title;

  @override
  int get hashCode => hashValues(title, start);

  bool operator <(Event other) => compareTo(other) < 0;

  bool operator <=(Event other) => compareTo(other) <= 0;

  bool operator >=(Event other) => compareTo(other) >= 0;

  bool operator >(Event other) => compareTo(other) > 0;

  /// Whether the event is recurring.
  bool get recurring => recurrence["rRule"] != null && recurrence["rRule"]!.contains("FREQ");

  /// Whether the event is recurring on a daily frequency.
  bool get daily => recurring && (recurrence["rRule"]?.contains("FREQ:DAILY") ?? false);

  /// Whether the event is recurring on a weekly frequency.
  bool get weekly => recurring && (recurrence["rRule"]?.contains("FREQ:WEEKLY") ?? false);

  /// Whether the event is recurring on a monthly frequency.
  bool get monthly => recurring && (recurrence["rRule"]?.contains("FREQ:MONTHLY") ?? false);

  /// Whether the event is recurring on a yearly frequency.
  bool get yearly => recurring && (recurrence["rRule"]?.contains("FREQ:YEARLY") ?? false);

  /// Frequency at which the event occurs.
  Frequency get frequency {
    if (recurring) {
      if (daily) {
        return Frequency.daily;
      } else if (weekly) {
        return Frequency.weekly;
      } else if (monthly) {
        return Frequency.monthly;
      } else if (yearly) {
        return Frequency.yearly;
      }
    }

    return Frequency.once;
  }

  /// Interval at which the event occurs (in days/weeks/months/years, depending on the frequency).
  /// 0 if the event is not a recurring event.
  int get interval => recurring
      ? int.tryParse((recurrence["rRule"]?.split(";") ?? [])
              .firstWhere((rule) => rule.startsWith("INTERVAL"), orElse: () => "INTERVAL=0")
              .split("=")
              .last) ??
          0
      : 0;

  /// Instances of the event (useful if the event is recurring).
  Iterable<Event> get instances {
    final endTime = end;

    if (endTime != null && frequency != Frequency.once) {
      final actions = <Frequency, DateTime Function(DateTime, int)>{
        Frequency.daily: (DateTime t, int interval) =>
            DateTime(t.year, t.month, t.day + interval, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
        Frequency.weekly: (DateTime t, int interval) =>
            DateTime(t.year, t.month, t.day + (7 * interval), t.hour, t.minute, t.second, t.millisecond, t.microsecond),
        Frequency.monthly: (DateTime t, int interval) => monthsLater(t: t, months: interval),
        Frequency.yearly: (DateTime t, int interval) =>
            DateTime(t.year + interval, t.month, t.day, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
      };

      List<Event> result = [];
      DateTime instanceTime = start;
      while (!instanceTime.isAfter(endTime)) {
        result.add(Event(title, start: instanceTime));
        instanceTime = actions[frequency]!(instanceTime, interval);
      }

      return result;
    }

    return {Event(title, start: start)};
  }
}

/// Frequency at which an [Event] can occur.
enum Frequency { once, daily, weekly, monthly, yearly }

/// Get a sequence of events named [title] with time inside [range] (including
/// the end), recurring on a [frequency] basis at intervals of [interval]
/// days/weeks/months/years (depending on the frequency).
Iterable<Event> recurringEvents({
  required String title,
  required DateTimeRange range,
  required Frequency frequency,
  int interval = 1,
}) {
  if (frequency == Frequency.once) {
    return {Event(title, start: range.start)};
  }

  final actions = <Frequency, DateTime Function(DateTime, int)>{
    Frequency.daily: (DateTime t, int interval) =>
        DateTime(t.year, t.month, t.day + interval, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.weekly: (DateTime t, int interval) =>
        DateTime(t.year, t.month, t.day + (7 * interval), t.hour, t.minute, t.second, t.millisecond, t.microsecond),
    Frequency.monthly: (DateTime t, int interval) => monthsLater(t: t, months: interval),
    Frequency.yearly: (DateTime t, int interval) =>
        DateTime(t.year + interval, t.month, t.day, t.hour, t.minute, t.second, t.millisecond, t.microsecond),
  };

  List<Event> result = [];
  DateTime time = range.start;
  while (!time.isAfter(range.end)) {
    result.add(Event(title, start: time));
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
