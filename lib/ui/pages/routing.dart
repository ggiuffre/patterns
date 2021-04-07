import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../data/event.dart';
import 'error.dart';
import 'event_details.dart';
import 'events_index.dart';
import 'new_event.dart';

class EventRoutePath {
  final String? id;
  final bool isUnknown;

  const EventRoutePath.home()
      : id = "/",
        isUnknown = false;

  const EventRoutePath.details(eventId)
      : id = "/events/$eventId",
        isUnknown = false;

  const EventRoutePath.newEvent()
      : id = "/new-event",
        isUnknown = false;

  const EventRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == "/";

  bool get isNewEventPage => id == "/new-event";

  bool get isDetailsPage => id?.startsWith("/events/") ?? false;
}

class EventRouterDelegate extends RouterDelegate<EventRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<EventRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;
  List<Event> _events = [];
  Event? _selectedEvent;
  bool _newEventNeeded = false;
  bool _show404 = false;

  EventRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: [
          MaterialPage(
            key: const ValueKey('/'),
            child: EventsIndexPage(
              events: _events,
              onEventTapped: (event) {
                _selectedEvent = event;
                notifyListeners();
              },
              onNewEvent: () {
                _newEventNeeded = true;
                notifyListeners();
              },
            ),
          ),
          if (_show404)
            const MaterialPage(
              key: ValueKey('/404'),
              child: ErrorPage(),
            )
          else if (_newEventNeeded)
            MaterialPage(
              key: const ValueKey('/new-event'),
              child: NewEventPage(
                onSave: (event) {
                  _events.add(event);
                  _newEventNeeded = false;
                  notifyListeners();
                },
              ),
            )
          else if (_selectedEvent != null)
            MaterialPage(
              key: ValueKey('/events/${_selectedEvent?.id ?? ""}'),
              child: EventDetailsPage(event: _selectedEvent!),
            ),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          _selectedEvent = null;
          _newEventNeeded = false;
          _show404 = false;
          notifyListeners();

          return true;
        },
      );

  @override
  Future<void> setNewRoutePath(EventRoutePath path) async {
    if (path.isUnknown) {
      _selectedEvent = null;
      _newEventNeeded = false;
      _show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id?.startsWith("/events/") ?? false) {
        final eventId = path.id?.replaceFirst("/events/", "");
        _selectedEvent = _events.firstWhere((element) => element.id == eventId);
      } else {
        _show404 = true;
        return;
      }
    } else if (path.isNewEventPage) {
      _selectedEvent = null;
      _newEventNeeded = true;
    } else {
      _selectedEvent = null;
      _newEventNeeded = false;
    }

    _show404 = false;
  }

  EventRoutePath get currentConfiguration {
    if (_show404) {
      return const EventRoutePath.unknown();
    }

    if (_newEventNeeded) {
      return const EventRoutePath.newEvent();
    }

    return _selectedEvent == null ? const EventRoutePath.home() : EventRoutePath.details(_selectedEvent?.id);
  }
}

class EventRouteInformationParser extends RouteInformationParser<EventRoutePath> {
  @override
  Future<EventRoutePath> parseRouteInformation(RouteInformation? routeInformation) async {
    final uri = Uri.parse(routeInformation?.location ?? "/");

    if (uri.pathSegments.length == 0) {
      // Handle '/'
      return EventRoutePath.home();
    }

    // Handle '/new-event' and 'events'
    if (uri.pathSegments.length == 1) {
      if (uri.pathSegments[0] == 'new-event') {
        return EventRoutePath.newEvent();
      } else if (uri.pathSegments[0] == 'events') {
        return EventRoutePath.home();
      } else {
        return EventRoutePath.unknown();
      }
    }

    if (uri.pathSegments.length == 2) {
      // Handle '/events/:id'
      if (uri.pathSegments[0] != 'events') return EventRoutePath.unknown();
      final remaining = uri.pathSegments[1];
      final id = remaining;
      // if (id == null) return EventRoutePath.unknown();
      return EventRoutePath.details(id);
    }

    // Handle unknown routes
    return EventRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(EventRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    } else if (path.isHomePage) {
      return RouteInformation(location: '/');
    } else if (path.isNewEventPage) {
      return RouteInformation(location: '/new-event');
    } else if (path.isDetailsPage) {
      return RouteInformation(location: path.id);
    }
    return null;
  }
}
