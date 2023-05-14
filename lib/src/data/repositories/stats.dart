import 'dart:math' show log;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../event.dart' show Event;
import 'event_providers.dart';

typedef EventTitle = String;
typedef Word = String;

final punctuationMatcher = RegExp(r"(\s+)|[!._\-,'@?/]");

/// Get a map that assigns term frequencies to each event title. A term
/// frequency is itself a map that assigns a frequency to each word in a title.
Map<EventTitle, Map<Word, double>> termFrequencies(Iterable<Event> events,
    {bool caseSensitive = false}) {
  final titles =
      events.map((e) => caseSensitive ? e.title : e.title.toLowerCase());
  final termFrequenciesByEventTitle = <EventTitle, Map<Word, double>>{};
  for (final title in titles) {
    final wordCounts = <Word, int>{};
    final words = title.split(punctuationMatcher).where((e) => e != '');
    for (final word in words) {
      wordCounts[word] = (wordCounts[word] ?? 0) + 1;
    }
    termFrequenciesByEventTitle[title] =
        wordCounts.map((key, value) => MapEntry(key, value / words.length));
  }
  return termFrequenciesByEventTitle;
}

/// Get how much information a word conveys across a corpus of event titles.
Map<Word, double> inverseDocumentFrequencies(Iterable<Event> events,
    {bool caseSensitive = false}) {
  final titles =
      events.map((e) => caseSensitive ? e.title : e.title.toLowerCase());
  final wordLists = titles
      .map((title) => title.split(punctuationMatcher).where((e) => e != ''));
  final words = wordLists.expand((i) => i).toSet();
  final wordPresence = {
    for (final word in words) word: _numDocumentsContainingWord(word, titles)
  };
  final inverseFrequencies = wordPresence
      .map((key, value) => MapEntry(key, log(events.length / value)));
  return inverseFrequencies;
}

/// Get how many strings contain a certain word, given an iterable of strings.
int _numDocumentsContainingWord(Word word, Iterable<String> documents) =>
    documents.fold(
      0,
      (count, doc) =>
          doc.split(punctuationMatcher).where((e) => e != '').contains(word)
              ? count + 1
              : count,
    );

/// TF-IDF, term frequency * inverse document frequency.
final tfidf = FutureProvider<Map<EventTitle, Map<Word, double>>>((ref) {
  final events = ref.watch(eventList).value ?? [];
  final tf = termFrequencies(events);
  final idf = inverseDocumentFrequencies(events);
  return tf.map((eventTitle, value) => MapEntry(
        eventTitle,
        value.map((word, value) => MapEntry(word, value * (idf[word] ?? 0.0))),
      ));
});
