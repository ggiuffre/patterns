import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as g;
import 'package:http/http.dart' as http;

import '../event.dart';
import '../google_data_provider.dart';

final eventList = FutureProvider<Iterable<Event>>((ref) => [
      ref.watch(firestoreEventList).value,
      ref.watch(googleCalendarEventList).value,
    ].fold<Iterable<Event>>(
      const Iterable.empty(),
      (accumulator, newEvents) =>
          newEvents != null ? accumulator.followedBy(newEvents) : accumulator,
    ));

final sortedEventList = FutureProvider<Iterable<Event>>((ref) {
  final events = ref.watch(eventList).value;
  if (events != null) {
    return events.toList()..sort((a, b) => b.compareTo(a));
  } else {
    return const Iterable.empty();
  }
});

final firestoreEventList = FutureProvider<Iterable<Event>>((_) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  return userId == null
      ? Future.error("Couldn't get events from Cloud Firestore.")
      : FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
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
});

final googleCalendarList =
    FutureProvider<Iterable<Iterable<Event>>>((ref) async {
  final google = ref.watch(googleDataProvider).value;
  final calendarIds = google?.enabledCalendarIds ?? const {};
  final calendarApi = (google != null && google.authHeaders != null)
      ? g.CalendarApi(_GoogleAuthClient(google.authHeaders!))
      : null;
  if (calendarApi != null) {
    developer.log("Retrieving Google calendar events...");
    return Future.wait(calendarIds.map((calendarId) async {
      String? pageToken;
      List<g.Event> events = [];
      do {
        final eventsComputation =
            await calendarApi.events.list(calendarId, pageToken: pageToken);
        pageToken = eventsComputation.nextPageToken;
        events.addAll(eventsComputation.items ?? const []);
      } while (pageToken != null);
      return events.map(Event.fromGoogleCalendar);
    }));
  } else {
    developer.log("No auth headers to retrieve Google Calendar events.");
    return Future.value({});
  }
});

final googleCalendarEventList = FutureProvider<Iterable<Event>>((ref) async {
  developer.log("Retrieving Google calendar events...");
  final calendars =
      ref.watch(googleCalendarList).value ?? const Iterable.empty();
  return calendars
      .fold(
        const Iterable<Event>.empty(),
        (accumulator, events) => accumulator.followedBy(events),
      )
      .toSet();
});

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _client.send(request..headers.addAll(_headers));
}
