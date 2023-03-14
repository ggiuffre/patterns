import 'event.dart';

class Category {
  final String title;
  final int count;

  const Category({required this.title, required this.count});
}

Iterable<Category> categoriesFromEvents(Iterable<Event> events) {
  final histogram = <String, int>{};
  for (final event in events) {
    histogram[event.title] = (histogram[event.title] ?? 0) + 1;
  }
  final sortedEntries = histogram.entries.toList()
    ..sort((e1, e2) {
      int diff = e2.value.compareTo(e1.value);
      if (diff == 0) diff = e2.key.compareTo(e1.key);
      return diff;
    });
  return sortedEntries.map((e) => Category(title: e.key, count: e.value));
}
