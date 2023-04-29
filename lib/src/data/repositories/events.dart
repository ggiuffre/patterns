import 'dart:async' show Future;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../google_data_provider.dart';
import '../event.dart';
import 'google_calendar.dart';

/// A read-only repository of [Event] objects.
abstract class EventRepository {
  /// Get the event identified by [id].
  Future<Event> get(String id);

  /// Future of iterable with all events stored in the repository.
  Future<Iterable<Event>> get list;
}

/// A repository of [Event] objects that can be read and written to.
abstract class WritableEventRepository extends EventRepository {
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

/// Currently selected implementation of [EventRepository].
final eventProvider = Provider<EventRepository>(
  (ref) => HybridEventRepository(
    repositories: [
      ref.watch(writableEventProvider),
      GoogleCalendarEventsRepository(ref.watch(googleDataProvider).value),
    ],
  ),
);

/// Implementation of [EventRepository] that reads merged events coming from a
/// list of several other repositories and writes to the first repository in
/// the list.
class HybridEventRepository implements EventRepository {
  final Iterable<EventRepository> repositories;

  HybridEventRepository({required this.repositories});

  @override
  Future<Event> get(String id) =>
      list.then((events) => events.firstWhere((element) => element.id == id));

  @override
  Future<Iterable<Event>> get list =>
      repositories.map((repository) => repository.list).fold(
            Future.value(const Iterable<Event>.empty()),
            (accumulator, events) => accumulator
                .then((value) async => value.followedBy(await events)),
          );
}

/// Implementation of [WritableEventRepository] with a Firestore back-end.
///
/// Events are only read from (and persisted to) Cloud Firestore if the app
/// user is currently logged via Firebase. Otherwise all methods of this class
/// return a future that resolves in an error or a future that emits an error.
class FirestoreEventRepository implements WritableEventRepository {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<Event> get(String id) => _userId == null
      ? Future.error("Couldn't retrieve event from Cloud Firestore.")
      : FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .doc(id)
          .get()
          .then((e) => Event.fromFirestore(
                e.data()?["title"],
                value: double.tryParse(e.data()?["value"] ?? "0") ?? 0,
                start: e.data()?["start"],
                end: e.data()?["end"],
                id: id,
              ));

  @override
  Future<String> add(Event event) async {
    if (_userId == null) {
      return Future.error("Couldn't persist event to Cloud Firestore.");
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
      ? Future.error("Couldn't delete event from Cloud Firestore.")
      : FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .doc(id)
          .delete();

  @override
  Future<Iterable<Event>> get list => _userId == null
      ? Future.error("Couldn't get events from Cloud Firestore.")
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
  Future<Event> get(String id) =>
      Future.value(events.firstWhere((e) => e.id == id));

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

  @override
  Future<Iterable<Event>> get list => Future.value(events);
}

/// Mock implementation of [WritableEventRepository], meant to be used in
/// widget tests.
class DummyEventRepository implements WritableEventRepository {
  const DummyEventRepository();

  @override
  Future<Event> get(String id) =>
      Future.value(Event("title", value: 1, start: DateTime(2020, 1, 1)));

  @override
  Future<String> add(Event event) => Future.value("id");

  @override
  Future<void> delete(String id) => Future.value();

  @override
  Future<Iterable<Event>> get list => Future.value(const {});

  @override
  Future<Iterable<Event>> sorted({bool descending = false}) =>
      Future.value(const {});
}
