import 'event.dart';

class Similarity {
  final Set<String> labels;
  final double coefficient;

  const Similarity(this.labels, this.coefficient);
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

  List<Similarity> coefficients = [
    for (final couple in couples)
      Similarity(
        {couple.first, couple.last},
        similarity(
          events.where((e) => e.title == couple.first).toList(),
          events.where((e) => e.title == couple.last).toList(),
        ),
      ),
  ];

  coefficients.sort((a, b) => a.coefficient.compareTo(b.coefficient));
  return coefficients;
}
