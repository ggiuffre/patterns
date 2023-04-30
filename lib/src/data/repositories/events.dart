import 'dart:async' show Future;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../event.dart';

/// A repository of [Event] objects.
abstract class WritableEventRepository {
  /// Persist [event] to the repository, and return an identifier to retrieve
  /// it.
  Future<String> add(Event event);

  /// Delete the event [id] from the repository.
  Future<void> delete(String id);
}

/// Currently selected implementation of [WritableEventRepository].
final writableEventProvider = Provider<WritableEventRepository>(
  (ref) => FirestoreEventRepository(),
);

/// Implementation of [WritableEventRepository] with a Firestore back-end.
///
/// Events are only read from (and persisted to) Cloud Firestore if the app
/// user is currently logged via Firebase. Otherwise all methods of this class
/// return a future that resolves in an error or a future that emits an error.
class FirestoreEventRepository implements WritableEventRepository {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<String> add(Event event) async {
    if (_userId == null) {
      return Future.error("Couldn't persist event to Cloud Firestore");
    }

    final matchingEvents = await list.then(
      (events) => events.where((e) =>
          e.title == event.title &&
          e.start.day == event.start.day &&
          e.start.month == event.start.month &&
          e.start.year == event.start.year),
    ); // TODO allow finer-grained events?

    if (matchingEvents.isNotEmpty) {
      final existingEvent = matchingEvents.first;
      final eventId = existingEvent.id;
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .doc(eventId)
          .update({
        "title": event.title,
        "value": (existingEvent.value + event.value).toString(),
        "start": event.start,
        "end": event.end,
      }).then((_) => eventId);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("events")
        .add({
      "title": event.title,
      "value": event.value.toString(),
      "start": event.start,
      "end": event.end,
    }).then((doc) => doc.id);
  }

  @override
  Future<void> delete(String id) => _userId == null
      ? Future.error("Couldn't delete event from Cloud Firestore")
      : FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .doc(id)
          .delete();

  Future<Iterable<Event>> get list => _userId == null
      ? Future.error("Couldn't get events from Cloud Firestore")
      : FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .snapshots()
          .first
          .then((snapshot) => snapshot.docs.map((e) => Event.fromFirestore(
                e.data()["title"],
                value: double.tryParse(e.data()["value"] ?? "0") ?? 0,
                start: e.data()["start"],
                end: e.data()["end"],
                id: e.id,
              )));
}

/// Implementation of [WritableEventRepository] that keeps events in memory
/// until the app closes.
class InMemoryEventRepository implements WritableEventRepository {
  List<Event> events = [];

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

    return Future.value(event.id);
  }

  @override
  Future<void> delete(String id) =>
      Future(() => events.removeWhere((e) => e.id == id));
}

/// Mock implementation of [WritableEventRepository], meant to be used in
/// widget tests.
class DummyEventRepository implements WritableEventRepository {
  const DummyEventRepository();

  @override
  Future<String> add(Event event) => Future.value("id");

  @override
  Future<void> delete(String id) => Future.value();
}
