import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:patterns/data/event.dart';

abstract class EventRepository {
  /// Get the event identified by [id]
  Future<Event> get(String id);

  /// Persist [event] to the repository
  Future<String> addEvent(Event event);

  /// Remove [event] from the repository
  Future<void> removeEvent(String id);

  /// Iterable of all events stored in the repository
  Future<Iterable<Event>> get list;

  /// Iterable of all events stored in the repository, sorted by descending date
  Future<Iterable<Event>> get sorted;
}

class FirestoreEventRepository implements EventRepository {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<Event> get(String id) {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .doc(id)
          .get()
          .then((e) => Event.fromFirestore(e.data()?["title"], e.data()?["time"]));
    }
    throw Future.error("Couldn't retrieve event from Cloud Firestore.");
  }

  @override
  Future<String> addEvent(Event event) {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .add({"title": event.title, "time": event.time}).then((doc) => doc.id);
    }
    throw Future.error("Couldn't persist event to Cloud Firestore.");
  }

  @override
  Future<void> removeEvent(String id) {
    if (_userId != null) {
      return FirebaseFirestore.instance.collection("users").doc(_userId).collection("events").doc(id).delete();
    }
    throw Future.error("Couldn't delete event from Cloud Firestore.");
  }

  @override
  Future<Iterable<Event>> get list {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .get()
          .then((collection) => collection.docs.map((e) => Event.fromFirestore(e.data()["title"], e.data()["time"])));
    }
    throw Future.error("Couldn't retrieve events from Cloud Firestore.");
  }

  @override
  Future<Iterable<Event>> get sorted {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .orderBy('time', descending: true)
          .get()
          .then((collection) => collection.docs.map((e) => Event.fromFirestore(e.data()["title"], e.data()["time"])));
    }
    throw Future.error("Couldn't retrieve events from Cloud Firestore.");
  }
}
