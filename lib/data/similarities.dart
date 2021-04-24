import 'event.dart';

double similarity(List<Event> a, List<Event> b) {
  double accumulator = 0.0;
  int samplesVisited = 0;
  int aIndex = 0;
  int bIndex = 0;

  while (aIndex < a.length && bIndex < b.length) {
    if (a[aIndex].time == b[bIndex].time) {
      accumulator += 1.0;
      aIndex++;
      bIndex++;
    } else if (a[aIndex].time.isBefore(b[bIndex].time)) {
      accumulator -= 1.0;
      aIndex++;
    } else {
      accumulator -= 1.0;
      bIndex++;
    }
    samplesVisited++;
  }

  return accumulator / samplesVisited;
}
