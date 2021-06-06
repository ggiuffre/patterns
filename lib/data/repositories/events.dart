import 'dart:async' show Future, Stream;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' show CalendarApi;
import 'package:http/http.dart' as http;

import '../app_settings_provider.dart';
import '../event.dart';

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
        Stream.value(Iterable<Event>.empty()),
        (accumulator, events) => accumulator.asyncMap((value) async => value.followedBy(await events.first)),
      );

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) {
    final result = list.map((events) => events.toList()..sort((a, b) => a.compareTo(b)));
    if (descending) {
      return result.map((events) => events.reversed);
    } else {
      return result;
    }
  }
}

/// Implementation of [EventRepository] with a Firestore back-end.
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
  Stream<Iterable<Event>> get list {
    if (_userId != null) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("events")
          .snapshots()
          .map((snapshot) => snapshot.docs.map((e) => Event.fromFirestore(e.data()["title"], e.data()["time"], e.id)));
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
          .orderBy('time', descending: descending)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((e) => Event.fromFirestore(e.data()["title"], e.data()["time"], e.id)));
    }
    throw Stream.error("Couldn't stream events from Cloud Firestore.");
  }
}

final googleCalendarEventProvider = Provider<GoogleCalendarEventsRepository>(
    (ref) => GoogleCalendarEventsRepository(ref.watch(appSettingsProvider).google));

/// Implementation of [EventRepository] that reads events from Google Calendar (and is not able to create new events).
class GoogleCalendarEventsRepository implements EventRepository {
  CalendarApi? _calendarApi;
  Set<String> _calendarIds;

  GoogleCalendarEventsRepository([GoogleData? google])
      : _calendarIds = google?.enabledCalendarIds ?? const {},
        _calendarApi = google?.authHeaders != null ? CalendarApi(_GoogleAuthClient(google!.authHeaders!)) : null;

  void enable(Map<String, String> headers) => _calendarApi = CalendarApi(_GoogleAuthClient(headers));

  void disable() => _calendarApi = null;

  bool get enabled => _calendarApi != null;

  @override
  Future<String> add(Event event) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Event> get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Stream<Iterable<Event>> get list {
    final api = _calendarApi;
    if (api != null) {
      print("Retrieving Google calendar events...");
      return _calendarIds
          .map(_eventsFromCalendarId)
          .fold(Future.value(Iterable<Event>.empty()), _chainEventComputations)
          .then((eventsList) => eventsList.toSet())
          .asStream();
    } else {
      print("No auth headers to retrieve Google Calendar events.");
      return Stream.value({});
    }
  }

  Future<Iterable<Event>> _eventsFromCalendarId(String calendarId) async {
    final api = _calendarApi;
    if (api != null) {
      final eventsComputation = await api.events.list(calendarId);
      final events = eventsComputation.items ?? const [];
      return events.map((e) => Event(e.summary ?? "", e.start?.dateTime ?? DateTime.now()));
    } else {
      return Future.value(Iterable<Event>.empty());
    }
  }

  Future<Iterable<Event>> _chainEventComputations(Future<Iterable<Event>> acc, Future<Iterable<Event>> events) =>
      acc.then((allEvents) async => allEvents.followedBy(await events));

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) {
    final result = list.map((events) => events.toList()..sort((a, b) => a.compareTo(b)));
    if (descending) {
      return result.map((events) => events.reversed);
    } else {
      return result;
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) => _client.send(request..headers.addAll(_headers));
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
  Stream<Iterable<Event>> sorted({bool descending = false}) =>
      Future.value(descending ? events.reversed : events).asStream();
}

/// Mock implementation of [EventRepository], meant to be used in widget tests.
class DummyEventRepository implements EventRepository {
  const DummyEventRepository();

  @override
  Future<Event> get(String id) => Future.value(Event("title", DateTime(2020, 1, 1)));

  @override
  Future<String> add(Event event) => Future.value("id");

  @override
  Future<void> delete(String id) async {
    await Future.value(1);
  }

  @override
  Stream<Iterable<Event>> get list => Stream.value([]);

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) => Stream.value([]);
}