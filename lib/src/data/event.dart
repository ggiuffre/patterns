import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart' show DateTimeRange;

class Event implements Comparable<Event> {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final Map<String, String?> recurrence;
  final double value;

  static const defaultRecurrence = <String, String?>{
    "rRule": null,
    "exRule": null,
    "rDate": null,
    "exDate": null
  };

  const Event(
    this.title, {
    required this.value,
    required this.start,
    this.end,
    this.recurrence = defaultRecurrence,
  }) : id = "$start$title";

  Event.fromFirestore(
    this.title, {
    required this.value,
    required Timestamp start,
    Timestamp? end,
    required this.id,
    this.recurrence = defaultRecurrence,
  })  : start = start.toDate(),
        end = end?.toDate();

  Map<String, String> get asJson => {
        "id": id,
        "title": title,
        "value": value.toString(),
        "start": start.toIso8601String(),
        "end": end?.toIso8601String() ?? "",
        "recurrence": recurrence.toString(),
      };

  @override
  int compareTo(Event other) => start == other.start
      ? title.compareTo(other.title)
      : start.compareTo(other.start);

  @override
  bool operator ==(Object other) =>
      other is Event && start == other.start && title == other.title;

  @override
  int get hashCode => Object.hash(title, start);

  bool operator <(Event other) => compareTo(other) < 0;

  bool operator <=(Event other) => compareTo(other) <= 0;

  bool operator >=(Event other) => compareTo(other) >= 0;

  bool operator >(Event other) => compareTo(other) > 0;

  /// Whether the event is recurring.
  bool get recurring =>
      recurrence["rRule"] != null && recurrence["rRule"]!.contains("FREQ");

  /// Whether the event is recurring on a daily frequency.
  bool get daily =>
      recurring && (recurrence["rRule"]?.contains("FREQ:DAILY") ?? false);

  /// Whether the event is recurring on a weekly frequency.
  bool get weekly =>
      recurring && (recurrence["rRule"]?.contains("FREQ:WEEKLY") ?? false);

  /// Whether the event is recurring on a monthly frequency.
  bool get monthly =>
      recurring && (recurrence["rRule"]?.contains("FREQ:MONTHLY") ?? false);

  /// Whether the event is recurring on a yearly frequency.
  bool get yearly =>
      recurring && (recurrence["rRule"]?.contains("FREQ:YEARLY") ?? false);

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
              .firstWhere((rule) => rule.startsWith("INTERVAL"),
                  orElse: () => "INTERVAL=0")
              .split("=")
              .last) ??
          0
      : 0;

  /// Instances of the event (useful if the event is recurring).
  Iterable<Event> get instances {
    final endTime = end;

    if (endTime != null && frequency != Frequency.once) {
      List<Event> result = [];
      DateTime instanceTime = start;
      while (!instanceTime.isAfter(endTime)) {
        result.add(Event(title, value: value, start: instanceTime));
        instanceTime = instanceTime.increaseByInterval(
            interval: interval, frequency: frequency);
      }

      return result;
    }

    return {Event(title, value: value, start: start)};
  }
}

/// Frequency at which an [Event] can occur.
enum Frequency { once, daily, weekly, monthly, yearly }

/// Get a sequence of events named [title] with time inside [range] (including
/// the end), recurring on a [frequency] basis at intervals of [interval]
/// days/weeks/months/years (depending on the frequency).
Iterable<Event> recurringEvents({
  required String title,
  required double value,
  required DateTimeRange range,
  required Frequency frequency,
  int interval = 1,
}) {
  if (frequency == Frequency.once) {
    return {Event(title, value: value, start: range.start)};
  }

  List<Event> result = [];
  DateTime time = range.start;
  while (!time.isAfter(range.end)) {
    result.add(Event(title, value: value, start: time));
    time = time.increaseByInterval(interval: interval, frequency: frequency);
  }

  return result;
}

extension IncreasableByInterval on DateTime {
  DateTime increaseByInterval({
    required int interval,
    required Frequency frequency,
  }) {
    if (frequency == Frequency.daily) {
      return DateTime.utc(year, month, day + interval, hour, minute, second,
          millisecond, microsecond);
    } else if (frequency == Frequency.weekly) {
      return DateTime.utc(year, month, day + (7 * interval), hour, minute,
          second, millisecond, microsecond);
    } else if (frequency == Frequency.monthly) {
      return monthsLater(months: interval);
    } else if (frequency == Frequency.yearly) {
      return DateTime.utc(year + interval, month, day, hour, minute, second,
          millisecond, microsecond);
    } else {
      throw Exception("Invalid frequency '$frequency'");
    }
  }

  DateTime monthsLater({required int months}) {
    DateTime candidate = DateTime.utc(year, month + months, day, hour, minute,
        second, millisecond, microsecond);
    int correction = 0;

    while (((candidate.month - month) % 12 > months.abs())) {
      correction++;
      candidate = DateTime.utc(
        year,
        month + months,
        day - (correction * months.sign),
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );
    }

    return candidate;
  }
}
