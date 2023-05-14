import 'stats.dart' show eventTags, EventTitle;

import 'event.dart';

class Category {
  final String title;
  final int count;

  const Category({required this.title, required this.count});
}

Iterable<Category> categoriesFromEvents(Iterable<Event> events,
    {bool caseSensitive = false, bool withTags = false}) {
  final histogram = <String, int>{};
  final tags = withTags
      ? eventTags(events, caseSensitive: caseSensitive)
      : <EventTitle, Iterable<String>>{};
  for (final event in events) {
    final title = caseSensitive ? event.title : event.title.toLowerCase();
    histogram[title] = (histogram[title] ?? 0) + 1;
    if (withTags) {
      final mostRelevantTag = tags[title]?.first;
      if (mostRelevantTag != null) {
        histogram[mostRelevantTag] = (histogram[mostRelevantTag] ?? 0) + 1;
      }
    }
  }
  final sortedEntries = histogram.entries.toList()
    ..sort((e1, e2) {
      int diff = e2.value.compareTo(e1.value);
      if (diff == 0) diff = e2.key.compareTo(e1.key);
      return diff;
    });
  return sortedEntries.map((e) => Category(title: e.key, count: e.value));
}
