import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../event.dart';
import '../similarities.dart';

/// A repository of [Similarity] objects.
abstract class SimilarityRepository {
  /// Get the similarity between two event iterables.
  Future<Similarity> get(Iterable<Event> aEvents, Iterable<Event> bEvents);
}

/// Implementation of [SimilarityRepository] with a Firestore back-end.
///
/// Similarities are only read from (and persisted to) Cloud Firestore if the
/// app user is currently logged via Firebase. Otherwise all methods of this
/// class return a future that resolves in an error or a future that emits an
/// error.
class FirestoreSimilarityRepository implements SimilarityRepository {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  /// Get the similarity between two event iterables, retrieving it from from
  /// Cloud Firestore if cached.
  @override
  Future<Similarity> get(Iterable<Event> aEvents, Iterable<Event> bEvents,
      {bool binary = false}) async {
    if (_userId == null) {
      return Future.error("Couldn't retrieve similarity from Cloud Firestore.");
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("similarities")
        .doc([aEvents, bEvents].hashCode.toString())
        .get()
        .then(
            (d) => Similarity(
                  {aEvents.first.title, bEvents.first.title},
                  double.tryParse(d.data()?["value"] ?? "0") ?? 0,
                ), onError: (_) {
      final sim = Similarity(
        {aEvents.first.title, bEvents.first.title},
        similarity(aEvents, bEvents, binary: binary),
      );
      _add([aEvents, bEvents].hashCode.toString(), sim.coefficient);
      return sim;
    });
  }

  /// Save a similarity to Cloud Firestore.
  Future<void> _add(String eventsHash, double coefficient) async {
    if (_userId == null) {
      return Future.error("Couldn't persist similarity to Cloud Firestore.");
    }

    FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("similarities")
        .add({
      "eventsHash": eventsHash,
      "value": coefficient,
    });
  }
}
