import 'dart:ui';

class Event implements Comparable {
  final String id;
  final String title;
  final DateTime time;

  Event(this.title, time)
      : time = DateTime(time.year, time.month, time.day),
        id = "$time$title";

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
