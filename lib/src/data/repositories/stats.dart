import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../event.dart';
import 'event_providers.dart';

/// Get a map that assigns term frequencies to each event title. A term
/// frequency is itself a map that assigns a count to each word in a title.
Map<String, Map<String, int>> termFrequencies(Iterable<Event> events) {
  final titles = events.map((e) => e.title);
  final termFrequenciesByEvent = <String, Map<String, int>>{};
  for (final title in titles) {
    final histogram = <String, int>{};
    for (final word in title.split(' ')) {
      histogram[word] = (histogram[word] ?? 0) + 1;
    }
    termFrequenciesByEvent[title] = histogram;
  }
  return termFrequenciesByEvent;
}

/// Get how often a word appears in a set of event titles.
Map<String, int> documentFrequencies(Iterable<Event> events) {
  final wordLists = events.map((e) => e.title.split(' '));
  final words = wordLists.expand((i) => i).toList();
  final frequencies = <String, int>{};
  for (final word in words) {
    frequencies[word] = (frequencies[word] ?? 0) + 1;
  }
  return frequencies;
}

/// TF-IDF, term frequency * inverse document frequency.
final tfidf = FutureProvider<Map<String, int>>((ref) {
  final events = ref.watch(eventList).value ?? [];
  return termFrequencies(events).map(
      (key, value) => MapEntry(key, documentFrequencies(events)[key] ?? 0));
});
