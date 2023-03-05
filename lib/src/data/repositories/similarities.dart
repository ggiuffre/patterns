import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../similarities.dart';

class SimilarityRepository {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  /// Save a similarity to Cloud Firestore.
  Future<void> add(Similarity similarity) async {
    if (_userId == null) {
      return Future.error("Couldn't persist event to Cloud Firestore.");
    }

    FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("similarities")
        .add({
      "labelsHash": similarity.labels.hashCode.toString(),
      "value": similarity.coefficient.toString(),
    });
  }

  /// Get a similarity from Cloud Firestore, given its [labels].
  Future<Similarity> get(Set<String> labels) => _userId == null
      ? Future.error("Couldn't retrieve similarity from Cloud Firestore.")
      : FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("similarities")
          .doc(labels.hashCode.toString())
          .get()
          .then((e) => Similarity(
                labels,
                double.tryParse(e.data()?["value"] ?? "0") ?? 0,
              ));
}