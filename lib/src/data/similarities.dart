import 'dart:math';

import 'event.dart';

class Similarity {
  final Set<String> labels;
  final double coefficient;

  const Similarity(this.labels, this.coefficient);
}

double covariance(List<Event> a, List<Event> b) {
  if (a.length != b.length) {
    throw "Cannot compute the covariance between lists of different length: ${a.length} != ${b.length}";
  }

  if (a.isEmpty) {
    return 1;
  }

  final n = a.length;

  return List.generate(n, (index) => index)
          .map((i) => (a[i].value - average(a)) * (b[i].value - average(b)))
          .reduce((x, y) => x + y) /
      n;
}

double stdDev(List<Event> events) {
  if (events.isEmpty) {
    return 1;
  }

  final n = events.length;

  return sqrt(List.generate(n, (index) => index)
          .map((i) => (events[i].value - average(events)) * (events[i].value - average(events)))
          .reduce((x, y) => x + y) /
      n);
}

double average(List<Event> events) => events.map((e) => e.value).reduce((a, b) => a + b) / events.length;

List<Event> interpolated(List<Event> events) {
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
            value: previousEvent.value + ((event.value - previousEvent.value) / (index + 1)),
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

double similarity(List<Event> a, List<Event> b) {
  double accumulator = 0.0;
  int samplesVisited = 0;
  int aIndex = 0;
  int bIndex = 0;

  while (aIndex < a.length && bIndex < b.length) {
    if (a[aIndex].start == b[bIndex].start) {
      accumulator += 1.0;
      aIndex++;
      bIndex++;
    } else if (a[aIndex].start.isBefore(b[bIndex].start)) {
      accumulator -= 1.0;
      aIndex++;
    } else {
      accumulator -= 1.0;
      bIndex++;
    }
    samplesVisited++;
  }

  if (aIndex < a.length) {
    final remaining = a.length - aIndex;
    accumulator -= remaining;
    samplesVisited += remaining;
  } else if (bIndex < b.length) {
    final remaining = b.length - bIndex;
    accumulator -= remaining;
    samplesVisited += remaining;
  }

  return accumulator / samplesVisited;
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
