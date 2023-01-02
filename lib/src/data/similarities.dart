import 'dart:math';

import 'event.dart';

class Similarity {
  final Set<String> labels;
  final double coefficient;

  const Similarity(this.labels, this.coefficient);
}

class CorrelationException implements Exception {
  String cause;
  CorrelationException(this.cause);
}

double correlation(Iterable<double> x, Iterable<double> y) {
  final n = x.length;
  final m = y.length;

  if (n != m) {
    throw CorrelationException(
        "Cannot compute the covariance between lists of different length: $n != $m");
  }

  if (n < 1) {
    return 1;
  }

  double sumX = 0;
  double sumY = 0;
  double sumXY = 0;
  double stdDevFractionX = 0;
  double stdDevFractionY = 0;

  for (var i = 0; i < n; i++) {
    sumX += x.elementAt(i);
    sumY += y.elementAt(i);
    sumXY += x.elementAt(i) * y.elementAt(i);
    stdDevFractionX += pow(x.elementAt(i), 2);
    stdDevFractionY += pow(y.elementAt(i), 2);
  }

  return (n * sumXY - sumX * sumY) /
      (sqrt(n * stdDevFractionX - pow(sumX, 2)) *
          sqrt(n * stdDevFractionY - pow(sumY, 2)));
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
    final distanceFromPreviousEvent =
        event.start.difference(previousDate).inDays;
    if (distanceFromPreviousEvent > 1) {
      missingEvents.addAll(
        List.generate(
          distanceFromPreviousEvent - 1,
          (index) => Event(
            title,
            value: binary
                ? 0
                : previousEvent.value +
                    ((event.value - previousEvent.value) / (index + 1)),
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

double similarity(Iterable<Event> originalA, Iterable<Event> originalB,
    {bool binary = false}) {
  final a = [...originalA];
  final b = [...originalB];

  if (a.isEmpty || b.isEmpty) {
    throw "Cannot compute similarity if one of the series is empty";
  }

  // series of non-adjacent 'unary' events is likely to be a series of binary events where
  // value 0 is encoded by the absence of an event, and value 1 by the presence of it:
  if (originalA.map((e) => e.value).toSet().length < 2) {
    binary = true;
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

  try {
    return correlation(
      interpolated(a, binary: binary).map((e) => e.value),
      interpolated(b, binary: binary).map((e) => e.value),
    );
  } on CorrelationException {
    return 0; // TODO figure out why some errors pop up
  }
}

class CategoryCouple {
  final String first;
  final String second;

  const CategoryCouple(this.first, this.second);
}

Set<CategoryCouple> couples(Iterable<Event> events) {
  final categories = events.map((e) => e.title).toSet();
  var couples = <CategoryCouple>{};
  var visitedCategories = <String>{};

  for (final a in categories) {
    for (final b in categories.difference({a})) {
      if (!visitedCategories.contains(b)) {
        couples.add(CategoryCouple(a, b));
      }
    }
    visitedCategories.add(a);
  }

  return couples;
}

List<Similarity> similarities(Iterable<Event> events) {
  Map<String, List<Event>> eventsByCategory = {};
  for (final event in events) {
    eventsByCategory.putIfAbsent(event.title, () => []).add(event);
  }

  List<Similarity> coefficients = [];
  Set visitedCategories = {};
  final categories = eventsByCategory.keys.toSet();
  for (final a in categories) {
    for (final b in categories.difference({a})) {
      if (!visitedCategories.contains(b) &&
          eventsByCategory.containsKey(a) &&
          eventsByCategory.containsKey(b)) {
        final aEvents = eventsByCategory[a]!;
        final bEvents = eventsByCategory[b]!;
        coefficients.add(Similarity({a, b}, similarity(aEvents, bEvents)));
      }
    }
    visitedCategories.add(a);
  }

  return coefficients..sort((a, b) => a.coefficient.compareTo(b.coefficient));
}
