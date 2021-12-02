import 'dart:math';

import 'event.dart';

class Similarity {
  final Set<String> labels;
  final double coefficient;

  const Similarity(this.labels, this.coefficient);
}

double correlation(Iterable<double> x, Iterable<double> y) {
  final n = x.length;
  final m = y.length;

  if (n != m) {
    throw "Cannot compute the covariance between lists of different length: $n != $m";
  }

  if (n < 1) {
    return 1;
  }

  double sumX = 0;
  double sumY = 0;
  double sumXY = 0;
  double stdDevFractionX = 0;
  double stdDevFractionY = 0;

  for (final i in List.generate(n, (index) => index, growable: false)) {
    sumX += x.elementAt(i);
    sumY += y.elementAt(i);
    sumXY += x.elementAt(i) * y.elementAt(i);
    stdDevFractionX += pow(x.elementAt(i), 2);
    stdDevFractionY += pow(y.elementAt(i), 2);
  }

  return (n * sumXY - sumX * sumY) /
      (sqrt(n * stdDevFractionX - pow(sumX, 2)) * sqrt(n * stdDevFractionY - pow(sumY, 2)));
}

List<Event> interpolated(List<Event> events, {bool binary = false}) {
  events.sort();

  if (events.length < 2) {
    return events;
  }

  final title = events.first.title;
  final missingEvents = <Event>[];

  var previousEvent = events.first;
  for (final event in events.skip(1)) {
    final previousDate = previousEvent.start;
    final distanceFromPreviousEvent = event.start.difference(previousDate).inDays;
    if (distanceFromPreviousEvent > 1) {
      missingEvents.addAll(
        List.generate(
          distanceFromPreviousEvent - 1,
          (index) => Event(
            title,
            value: binary ? 0 : previousEvent.value + ((event.value - previousEvent.value) / (index + 1)),
            start: previousDate.add(Duration(days: index + 1)),
          ),
        ),
      );
    }
    previousEvent = event;
  }

  events.addAll(missingEvents);
  events.sort();
  return events;
}

double similarity(Iterable<Event> originalA, Iterable<Event> originalB, {bool binary = false}) {
  final a = [...originalA];
  final b = [...originalB];

  if (a.isEmpty || b.isEmpty) {
    throw "Cannot compute similarity if one of the series is empty";
  }

  a.sort();
  b.sort();

  if (a.first.start.isBefore(b.first.start)) {
    b.insert(0, Event(b.first.title, value: 0, start: a.first.start));
  } else if (b.first.start.isBefore(a.first.start)) {
    a.insert(0, Event(a.first.title, value: 0, start: b.first.start));
  }

  if (a.last.start.isAfter(b.last.start)) {
    b.add(Event(b.last.title, value: 0, start: a.last.start));
  } else if (b.last.start.isAfter(a.last.start)) {
    a.add(Event(a.last.title, value: 0, start: b.last.start));
  }

  return correlation(
      interpolated(a, binary: binary).map((e) => e.value), interpolated(b, binary: binary).map((e) => e.value));
}

List<Similarity> similarities(Iterable<Event> events, Set<String>? categories) {
  categories ??= events.map((e) => e.title).toSet();

  Set couples = {};
  Set visitedCategories = {};
  for (final a in categories) {
    for (final b in categories.difference({a})) {
      if (!visitedCategories.contains(b)) {
        couples.add({a, b});
      }
    }
    visitedCategories.add(a);
  }

  return couples
      .map((couple) => Similarity(
            {couple.first, couple.last},
            similarity(
              events.where((e) => e.title == couple.first).toList(),
              events.where((e) => e.title == couple.last).toList(),
            ),
          ))
      .toList()
    ..sort((a, b) => a.coefficient.compareTo(b.coefficient));
}
