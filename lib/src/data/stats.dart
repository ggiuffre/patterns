import 'dart:math' show log;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'event.dart' show Event;
import 'repositories/event_providers.dart';

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

/// Get the TF-IDF scores of some events (term frequency * inverse document
/// frequency).
Map<EventTitle, Map<Word, double>> tfidfScores(Iterable<Event> events,
    {bool caseSensitive = false}) {
  final tf = termFrequencies(events, caseSensitive: caseSensitive);
  final idf = inverseDocumentFrequencies(events, caseSensitive: caseSensitive);
  return tf.map((eventTitle, value) => MapEntry(
        eventTitle,
        value.map((word, value) => MapEntry(word, value * (idf[word] ?? 0.0))),
      ));
}

Map<EventTitle, Iterable<String>> eventTags(Iterable<Event> events,
    {bool caseSensitive = false}) {
  final tfidf = tfidfScores(events, caseSensitive: caseSensitive);
  final tags = <EventTitle, Iterable<String>>{};
  for (final eventScores in tfidf.entries) {
    final entries = eventScores.value.entries.toList();
    entries.sort(((a, b) => a.value.compareTo(b.value)));
    tags[eventScores.key] = entries
        .map((e) => e.key)
        .where((tag) => tag != eventScores.key && tag.length > 1);
  }
  return tags;
}
