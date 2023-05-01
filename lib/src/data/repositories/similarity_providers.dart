import 'dart:convert' show utf8;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart' show sha1;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart' show Logger;

import '../category.dart';
import '../event.dart';
import '../similarities.dart';
import 'event_providers.dart';

final _logger = Logger((similarityList).toString());

final similarityList = FutureProvider<Iterable<Similarity>>((ref) async {
  final events = ref.watch(eventList).value ?? [];
  const binary = false; // TODO compute similarities between binary events

  Map<String, List<Event>> eventsByCategory = {};
  for (final event in _batchEvents(events).first ?? const Iterable.empty()) {
    eventsByCategory.putIfAbsent(event.title, () => []).add(event);
  }

  final cachedSimilarities = await _fetchAll();

  List<Similarity> coefficients = [];
  Set visitedCategories = {};
  final categories = eventsByCategory.keys.toSet();
  for (final a in categories) {
    for (final b in categories) {
      if (a != b &&
          !visitedCategories.contains(b) &&
          eventsByCategory.containsKey(a) &&
          eventsByCategory.containsKey(b)) {
        final aEvents = eventsByCategory[a]!..sort();
        final bEvents = eventsByCategory[b]!..sort();
        final similarityHash = _eventPairHash(aEvents, bEvents);
        if (cachedSimilarities.containsKey(similarityHash) &&
            cachedSimilarities[similarityHash] != null) {
          coefficients.add(
            Similarity(
              {aEvents.first.title, bEvents.first.title},
              cachedSimilarities[similarityHash]!,
            ),
          );
        } else {
          final similarityHash = _eventPairHash(aEvents, bEvents);
          final similarityCoefficient =
              similarity(aEvents, bEvents, binary: binary);
          await _add(similarityHash, similarityCoefficient);
          coefficients.add(
            Similarity({aEvents.first.title, bEvents.first.title},
                similarityCoefficient),
          );
        }
      }
    }
    visitedCategories.add(a);
  }

  return coefficients..sort((a, b) => a.coefficient.compareTo(b.coefficient));
});

/// Generate batches of events ordered from most to least relevant, taken from
/// an iterable of events. Relevance is event title frequency, and each
/// element of the iterable generated is a batch of at most [batchSize] events.
Iterable<Iterable<Event>?> _batchEvents(final Iterable<Event> events,
    [final int batchSize = 10]) sync* {
  final categories = categoriesFromEvents(events);
  final categoryBatch = <String>{};
  int i = 0;
  while (i < categories.length && categories.elementAt(i).count > 1) {
    categoryBatch.add(categories.elementAt(i).title);
    if (categoryBatch.length >= batchSize) {
      _logger.info("Returning a batch of events...");
      yield events.where((e) => categoryBatch.contains(e.title));
      categoryBatch.clear();
    }
    i++;
  }

  yield null;
}

/// Retrieve all similarities stored on Cloud Firestore.
Future<Map<String, double>> _fetchAll() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Future.error("Couldn't retrieve similarities from Cloud Firestore");
  }

  _logger.info("Retrieving similarities from Cloud Firestore...");
  return FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("similarities")
      .snapshots()
      .first
      .then((snapshot) => Map.fromEntries(snapshot.docs.map((e) => MapEntry(
            e.id,
            e.data()["value"] ?? 0,
          ))));
}

/// Get the SHA1 hash of two lists of events, as a string.
String _eventPairHash(List<Event> aEvents, List<Event> bEvents) => sha1
    .convert(utf8.encode(
      aEvents.map((e) => e.hashCode).join() +
          bEvents.map((e) => e.hashCode).join(),
    ))
    .toString();

/// Save a similarity to Cloud Firestore.
Future<void> _add(String similarityHash, double similarityCoefficient) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Future.error("Couldn't persist similarity to Cloud Firestore");
  }

  _logger.info("Saving new similarity to Cloud Firestore...");
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("similarities")
      .doc(similarityHash)
      .set({"value": similarityCoefficient});
}
