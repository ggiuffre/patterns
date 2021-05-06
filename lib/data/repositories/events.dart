import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../event.dart';

abstract class EventRepository {
  /// Get the event identified by [id].
  Future<Event> get(String id);

  /// Persist [event] to the repository, and return an identifier to retrieve it.
  Future<String> add(Event event);

  /// Delete [event] from the repository.
  Future<void> delete(String id);

  /// Iterable of all events stored in the repository.
  Future<Iterable<Event>> get list;

  /// Iterable of all events stored in the repository, sorted by date (default ascending).
  Future<Iterable<Event>> sorted({bool descending = false});
}

/// Currently selected implementation of [EventRepository].
final eventProvider = Provider((_) => FirestoreEventRepository());

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
          .then((e) => Event.fromFirestore(e.data()?["title"], e.data()?["time"], id));
    }
    throw Future.error("Couldn't retrieve event from Cloud Firestore.");
  }

  @override
  Future<String> add(Event event) {
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
  Future<void> delete(String id) {
    if (_userId != null) {
      return FirebaseFirestore.instance.collection("users").doc(_userId).collection("events").doc(id).delete();
    }
    throw Future.error("Couldn't delete event from Cloud Firestore.");
  }

  @override
  Future<Iterable<Event>> get list {
    if (_userId != null) {
      return FirebaseFirestore.instance.collection("users").doc(_userId).collection("events").get().then(
          (collection) => collection.docs.map((e) => Event.fromFirestore(e.data()["title"], e.data()["time"], e.id)));
    }
    throw Future.error("Couldn't retrieve events from Cloud Firestore.");
  }

  @override
  Future<Iterable<Event>> sorted({bool descending = false}) {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .orderBy('time', descending: descending)
          .get()
          .then((collection) =>
              collection.docs.map((e) => Event.fromFirestore(e.data()["title"], e.data()["time"], e.id)));
    }
    throw Future.error("Couldn't retrieve events from Cloud Firestore.");
  }
}

class InMemoryEventRepository implements EventRepository {
  List<Event> events = [];

  @override
  Future<Event> get(String id) => Future.value(events.firstWhere((e) => e.id == id));

  @override
  Future<String> add(Event event) {
    // add the event at the end:
    events.add(event);

    // sort the list, assuming it is mostly sorted:
    for (int i = 0; i < events.length; i++) {
      Event key = events[i];
      int j = i - 1;
      while (j >= 0 && key < events[j]) {
        events[j + 1] = events[j];
        j--;
      }
      events[j + 1] = key;
    }

    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) => Future(() => events.removeWhere((e) => e.id == id));

  @override
  Future<Iterable<Event>> get list => Future.value(events);

  @override
  Future<Iterable<Event>> sorted({bool descending = false}) =>
      descending ? list.then((v) => v.toList().reversed) : list;
}
