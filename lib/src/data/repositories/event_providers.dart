import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as g;
import 'package:http/http.dart' as http;

import '../event.dart';
import '../google_data_provider.dart';

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
      final y = events.map(_eventFromGoogleCalendar);
      return y;
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

Event _eventFromGoogleCalendar(g.Event event) {
  final eventTitle = event.summary ?? "untitled";
  final startDate = event.start?.date;
  final endDate = event.end?.date;
  final startDateTime = event.start?.dateTime;
  final endDateTime = event.end?.dateTime;
  final eventRecurrence = event.recurrence;

  // TODO using Event.defaultRecurrence makes recurrenceProperties immutable, so what follows is a temp. patch:
  final recurrenceProperties = <String, String?>{
    "rRule": null,
    "exRule": null,
    "rDate": null,
    "exDate": null
  };
  if (eventRecurrence != null) {
    recurrenceProperties["rRule"] = eventRecurrence
        .singleWhere((rule) => rule.startsWith("RRULE:"), orElse: () => "")
        .replaceFirst("RRULE:", "");
    recurrenceProperties["exRule"] = eventRecurrence
        .singleWhere((rule) => rule.startsWith("EXRULE:"), orElse: () => "")
        .replaceFirst("EXRULE:", "");
    recurrenceProperties["rDate"] = eventRecurrence
        .singleWhere((date) => date.startsWith("RDATE:"), orElse: () => "")
        .replaceFirst("RDATE:", "");
    recurrenceProperties["exDate"] = eventRecurrence
        .singleWhere((date) => date.startsWith("EXDATE:"), orElse: () => "")
        .replaceFirst("EXDATE:", "");
  }

  if (startDateTime != null) {
    return Event(eventTitle,
        value: 1,
        start: startDateTime,
        end: endDateTime,
        recurrence: recurrenceProperties);
  } else if (startDate != null) {
    return Event(eventTitle,
        value: 1,
        start: startDate,
        end: endDate,
        recurrence: recurrenceProperties);
  } else {
    return Event(eventTitle, value: 1, start: DateTime.now());
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _client.send(request..headers.addAll(_headers));
}
