import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patterns/src/data/repositories/events.dart';

import '../category.dart';
import '../event.dart';
import '../similarities.dart';

/// A repository of [Similarity] objects.
abstract class SimilarityRepository {
  /// Get a list of similarities between all available events.
  Future<List<Similarity>> list({bool binary = false});
}

/// Currently selected implementation of [SimilarityRepository].
final similarityProvider = FutureProvider<SimilarityRepository>(
  (ref) async =>
      FirestoreSimilarityRepository(await ref.watch(eventProvider).list),
);

/// Implementation of [SimilarityRepository] with a Cloud Firestore back-end.
///
/// Similarities are only read from (and persisted to) Cloud Firestore if the
/// app user is currently logged via Firebase. Otherwise all methods of this
/// class return a future that resolves in an error or a future that emits an
/// error.
class FirestoreSimilarityRepository implements SimilarityRepository {
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  final Iterable<Event> events;

  FirestoreSimilarityRepository(this.events);

  /// Get a list of similarities between all available events, reading
  /// and/or updating the Cloud Firestore cache.
  @override
  Future<List<Similarity>> list({bool binary = false}) async {
    developer.log("Listing all similarities",
        name: "FirestoreSimilarityRepository");
    Map<String, List<Event>> eventsByCategory = {};
    for (final event in _nextEvents()) {
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
  }

  /// Get the [maxNumCategories] most relevant events from the current event
  /// provider, where relevance is event title frequency.
  Iterable<Event> _nextEvents([int maxNumCategories = 10]) {
    developer.log("Getting next batch of events.",
        name: "FirestoreSimilarityRepository");
    final categories = categoriesFromEvents(events);
    final topCategories = categories
        .takeWhile((category) => maxNumCategories-- > 0 && category.count > 1);
    final categoryTitles = topCategories.map((c) => c.title).toSet();
    return events.where((e) => categoryTitles.contains(e.title));
  }

  /// Retrieve all similarities stored on Cloud Firestore.
  Future<Map<String, double>> _fetchAll() async {
    if (_userId == null) {
      return Future.error("Couldn't retrieve similarity from Cloud Firestore.");
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("similarities")
        .snapshots()
        .first
        .then((snapshot) => Map.fromEntries(snapshot.docs.map((e) => MapEntry(
              e.id,
              e.data()["value"] ?? 0,
            ))));
  }

  /// Retrieve the similarity between two event lists from Cloud Firestore.
  Future<Similarity> _get(List<Event> aEvents, List<Event> bEvents,
      {bool binary = false}) async {
    if (_userId == null) {
      return Future.error("Couldn't retrieve similarity from Cloud Firestore.");
    }

    final similarityHash = _eventPairHash(aEvents, bEvents);

    return FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("similarities")
        .doc(similarityHash)
        .get()
        .then((snapshot) => Similarity(
              {aEvents.first.title, bEvents.first.title},
              snapshot.data()?["value"] ?? 0,
            ));
  }

  /// Save a similarity to Cloud Firestore.
  Future<void> _add(String similarityHash, double similarityCoefficient) async {
    if (_userId == null) {
      return Future.error("Couldn't persist similarity to Cloud Firestore.");
    }

    developer.log("Saving new similarity to Cloud Firestore.",
        name: "FirestoreSimilarityRepository");

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("similarities")
        .doc(similarityHash)
        .set({"value": similarityCoefficient});
  }
}

/// Get the SHA1 hash of two lists of events, as a string.
String _eventPairHash(List<Event> aEvents, List<Event> bEvents) => sha1
    .convert(utf8.encode(
      aEvents.map((e) => e.hashCode).join() +
          bEvents.map((e) => e.hashCode).join(),
    ))
    .toString();

/// Implementation of [SimilarityRepository] that keeps similarities in memory
/// until the app closes.
class InMemorySimilarityRepository implements SimilarityRepository {
  final Iterable<Event> events;

  InMemorySimilarityRepository(this.events);

  @override
  Future<List<Similarity>> list({bool binary = false}) {
    Map<String, List<Event>> eventsByCategory = {};
    for (final event in events) {
      eventsByCategory.putIfAbsent(event.title, () => []).add(event);
    }

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
          coefficients.add(
            Similarity(
              {aEvents.first.title, bEvents.first.title},
              similarity(aEvents, bEvents, binary: binary),
            ),
          );
        }
      }
      visitedCategories.add(a);
    }

    return Future.value(
        coefficients..sort((a, b) => a.coefficient.compareTo(b.coefficient)));
  }
}
