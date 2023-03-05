import 'dart:developer' as developer;

import 'package:googleapis/calendar/v3.dart' as g;
import 'package:http/http.dart' as http;

import '../app_settings_provider.dart';
import '../event.dart';
import 'events.dart';

/// Implementation of [EventRepository] that reads events from Google Calendar
/// (and is not able to create new events).
///
/// Events from Google Calendar are only read if [GoogleCalendarEventsRepository]
/// is passed a [GoogleData] object whose user is signed in. Until the
/// [GoogleData] object's user is not signed in, this class will provide an
/// empty list of events.
class GoogleCalendarEventsRepository implements EventRepository {
  final g.CalendarApi? _calendarApi;
  final Set<String> _calendarIds;

  GoogleCalendarEventsRepository([GoogleData? google])
      : _calendarIds = google?.enabledCalendarIds ?? const {},
        _calendarApi = (google != null && google.authHeaders != null)
            ? g.CalendarApi(_GoogleAuthClient(google.authHeaders!))
            : null;

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
      developer.log("Retrieving Google calendar events...");
      return _calendarIds
          .map(_eventsFromCalendarId)
          .fold(Future.value(const Iterable<Event>.empty()), _chainEventComputations)
          .then((eventsList) => eventsList.toSet())
          .asStream();
    } else {
      developer.log("No auth headers to retrieve Google Calendar events.");
      return Stream.value({});
    }
  }

  Future<Iterable<Event>> _eventsFromCalendarId(String calendarId) async {
    final api = _calendarApi;
    if (api != null) {
      String? pageToken;
      List<g.Event> events = [];
      do {
        final eventsComputation = await api.events.list(calendarId, pageToken: pageToken);
        pageToken = eventsComputation.nextPageToken;
        events.addAll(eventsComputation.items ?? const []);
      } while (pageToken != null);
      return events.map(_eventFromGoogleCalendar);
    } else {
      return Future.value(const Iterable<Event>.empty());
    }
  }

  Event _eventFromGoogleCalendar(g.Event event) {
    final eventTitle = event.summary ?? "untitled";
    final startDate = event.start?.date;
    final endDate = event.end?.date;
    final startDateTime = event.start?.dateTime;
    final endDateTime = event.end?.dateTime;
    final eventRecurrence = event.recurrence;

    // TODO using Event.defaultRecurrence makes recurrenceProperties immutable, so what follows is a temp. patch:
    final recurrenceProperties = <String, String?>{"rRule": null, "exRule": null, "rDate": null, "exDate": null};
    if (eventRecurrence != null) {
      recurrenceProperties["rRule"] =
          eventRecurrence.singleWhere((rule) => rule.startsWith("RRULE:"), orElse: () => "").replaceFirst("RRULE:", "");
      recurrenceProperties["exRule"] = eventRecurrence
          .singleWhere((rule) => rule.startsWith("EXRULE:"), orElse: () => "")
          .replaceFirst("EXRULE:", "");
      recurrenceProperties["rDate"] =
          eventRecurrence.singleWhere((date) => date.startsWith("RDATE:"), orElse: () => "").replaceFirst("RDATE:", "");
      recurrenceProperties["exDate"] = eventRecurrence
          .singleWhere((date) => date.startsWith("EXDATE:"), orElse: () => "")
          .replaceFirst("EXDATE:", "");
    }

    if (startDateTime != null) {
      return Event(eventTitle, value: 1, start: startDateTime, end: endDateTime, recurrence: recurrenceProperties);
    } else if (startDate != null) {
      return Event(eventTitle, value: 1, start: startDate, end: endDate, recurrence: recurrenceProperties);
    } else {
      return Event(eventTitle, value: 1, start: DateTime.now());
    }
  }

  Future<Iterable<Event>> _chainEventComputations(Future<Iterable<Event>> acc, Future<Iterable<Event>> events) =>
      acc.then((allEvents) async => allEvents.followedBy(await events));

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) => descending
      ? list.map((events) => events.toList()..sort((a, b) => b.compareTo(a)))
      : list.map((events) => events.toList()..sort((a, b) => a.compareTo(b)));
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _client.send(request..headers.addAll(_headers));
}
