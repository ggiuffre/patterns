import 'dart:async' show Future;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../google_data_provider.dart';
import '../event.dart';
import 'google_calendar.dart';

/// A repository of [Event] objects.
abstract class EventRepository {
  /// Get the event identified by [id].
  Future<Event> get(String id);

  /// Persist [event] to the repository, and return an identifier to retrieve
  /// it.
  Future<String> add(Event event);

  /// Delete the event [id] from the repository.
  Future<void> delete(String id);

  /// Future of iterable with all events stored in the repository.
  Future<Iterable<Event>> get list;

  /// Future of iterable with all events stored in the repository, sorted by
  /// date (default ascending).
  Future<Iterable<Event>> sorted({bool descending = false});
}

/// Currently selected implementation of [EventRepository].
final eventProvider = Provider<EventRepository>(
  (ref) => HybridEventRepository(
    repositories: [
      FirestoreEventRepository(),
      GoogleCalendarEventsRepository(
        ref.watch(googleDataProvider).whenOrNull(data: (value) => value),
      ),
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
  Future<String> add(Event event) => repositories.first.add(event);

  @override
  Future<void> delete(String id) => repositories.first.delete(id);

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

  @override
  Future<Iterable<Event>> sorted({bool descending = false}) => descending
      ? list.then((events) => events.toList()..sort((a, b) => b.compareTo(a)))
      : list.then((events) => events.toList()..sort((a, b) => a.compareTo(b)));
}

/// Implementation of [EventRepository] with a Firestore back-end.
///
/// Events are only read from (and persisted to) Cloud Firestore if the app
/// user is currently logged via Firebase. Otherwise all methods of this class
/// return a future that resolves in an error or a future that emits an error.
class FirestoreEventRepository implements EventRepository {
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

  @override
  Future<Iterable<Event>> sorted({bool descending = false}) => _userId == null
      ? Future.error("Couldn't get events from Cloud Firestore.")
      : FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .orderBy("start", descending: descending)
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

/// Implementation of [EventRepository] that keeps events in memory until the
/// app closes.
class InMemoryEventRepository implements EventRepository {
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

  @override
  Future<Iterable<Event>> sorted({bool descending = false}) =>
      Future.value(descending ? events.reversed : events);
}

/// Mock implementation of [EventRepository], meant to be used in widget tests.
class DummyEventRepository implements EventRepository {
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
