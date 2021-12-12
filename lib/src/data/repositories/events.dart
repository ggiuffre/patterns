import 'dart:async' show Future, Stream;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_settings_provider.dart';
import '../event.dart';
import 'google_calendar.dart';

/// A repository of [Event] objects.
abstract class EventRepository {
  /// Get the event identified by [id].
  Future<Event> get(String id);

  /// Persist [event] to the repository, and return an identifier to retrieve it.
  Future<String> add(Event event);

  /// Delete [event] from the repository.
  Future<void> delete(String id);

  /// Stream of iterable with all events stored in the repository.
  Stream<Iterable<Event>> get list;

  /// Stream of iterable with all events stored in the repository, sorted by date (default ascending).
  Stream<Iterable<Event>> sorted({bool descending = false});
}

/// Currently selected implementation of [EventRepository].
final eventProvider = Provider<EventRepository>((ref) => HybridEventRepository(repositories: [
      FirestoreEventRepository(),
      GoogleCalendarEventsRepository(ref.watch(appSettingsProvider).google),
    ]));

/// Implementation of [EventRepository] that merges the events coming from several other repositories
class HybridEventRepository implements EventRepository {
  final Iterable<EventRepository> repositories;

  HybridEventRepository({required this.repositories});

  @override
  Future<String> add(Event event) => repositories.first.add(event);

  @override
  Future<void> delete(String id) => repositories.first.delete(id);

  @override
  Future<Event> get(String id) => list.map((events) => events.firstWhere((element) => element.id == id)).last;

  @override
  Stream<Iterable<Event>> get list => repositories
      .map(
        (repository) => repository.list,
      )
      .fold(
        Stream.value(const Iterable<Event>.empty()),
        (accumulator, events) => accumulator.asyncMap((value) async => value.followedBy(await events.first)),
      );

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) => descending
      ? list.map((events) => events.toList()..sort((a, b) => b.compareTo(a)))
      : list.map((events) => events.toList()..sort((a, b) => a.compareTo(b)));
}

/// Implementation of [EventRepository] with a Firestore back-end.
///
/// Events are only read from (and persisted to) Cloud Firestore if the app
/// user is currently logged via Firebase. Otherwise all methods of this class
/// return a future that resolves in an error.
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
          .then((e) => Event.fromFirestore(
                e.data()?["title"],
                value: double.tryParse(e.data()?["value"] ?? "0") ?? 0,
                start: e.data()?["start"],
                end: e.data()?["end"],
                id: id,
              ));
    }
    throw Future.error("Couldn't retrieve event from Cloud Firestore.");
  }

  @override
  Future<String> add(Event event) async {
    if (_userId != null) {
      final matchingEvents = await list.first.then((events) => events.where((e) =>
          e.title == event.title &&
          e.start.day == event.start.day &&
          e.start.month == event.start.month &&
          e.start.year == event.start.year)); // TODO allow finer-grained events?

      if (matchingEvents.isNotEmpty) {
        final existingEvent = matchingEvents.first;
        final eventId = existingEvent.id;
        return FirebaseFirestore.instance.collection("users").doc(_userId).collection("events").doc(eventId).update({
          "title": event.title,
          "value": (existingEvent.value + event.value).toString(),
          "start": event.start,
          "end": event.end,
        }).then((_) => eventId);
      }

      return FirebaseFirestore.instance.collection("users").doc(_userId).collection("events").add({
        "title": event.title,
        "value": event.value.toString(),
        "start": event.start,
        "end": event.end,
      }).then((doc) => doc.id);
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
  Stream<Iterable<Event>> get list {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .snapshots()
          .map((snapshot) => snapshot.docs.map((e) => Event.fromFirestore(
                e.data()["title"],
                value: double.tryParse(e.data()["value"] ?? "0") ?? 0,
                start: e.data()["start"],
                end: e.data()["end"],
                id: e.id,
              )));
    }
    throw Stream.error("Couldn't stream events from Cloud Firestore.");
  }

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .orderBy("start", descending: descending)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((e) => Event.fromFirestore(
                e.data()["title"],
                value: double.tryParse(e.data()["value"] ?? "0") ?? 0,
                start: e.data()["start"],
                end: e.data()["end"],
                id: e.id,
              )));
    }
    throw Stream.error("Couldn't stream events from Cloud Firestore.");
  }
}

/// Implementation of [EventRepository] that keeps events in memory until the app closes.
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

    return Future.value(event.id);
  }

  @override
  Future<void> delete(String id) => Future(() => events.removeWhere((e) => e.id == id));

  @override
  Stream<Iterable<Event>> get list => Stream.value(events);

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) => Stream.value(descending ? events.reversed : events);
}

/// Mock implementation of [EventRepository], meant to be used in widget tests.
class DummyEventRepository implements EventRepository {
  const DummyEventRepository();

  @override
  Future<Event> get(String id) => Future.value(Event("title", value: 1, start: DateTime(2020, 1, 1)));

  @override
  Future<String> add(Event event) => Future.value("id");

  @override
  Future<void> delete(String id) => Future.value();

  @override
  Stream<Iterable<Event>> get list => Stream.value(const {});

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) => Stream.value(const {});
}
