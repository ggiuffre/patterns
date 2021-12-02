import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import 'category_details.dart';
import 'error.dart';
import 'event_details.dart';
import 'home.dart';
import 'new_event.dart';

class EventRoutePath {
  final String? id;
  final bool isUnknown;

  const EventRoutePath.home()
      : id = "/",
        isUnknown = false;

  const EventRoutePath.categories()
      : id = "/categories",
        isUnknown = false;

  const EventRoutePath.patterns()
      : id = "/patterns",
        isUnknown = false;

  const EventRoutePath.categoryDetails(title)
      : id = "/categories/$title",
        isUnknown = false;

  const EventRoutePath.eventDetails(eventId)
      : id = "/events/$eventId",
        isUnknown = false;

  const EventRoutePath.newEvent()
      : id = "/new-event",
        isUnknown = false;

  const EventRoutePath.settings()
      : id = "/settings",
        isUnknown = false;

  const EventRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == "/";

  bool get isCategoriesPage => id == "/categories";

  bool get isCategoryDetailsPage => id?.startsWith("/categories/") ?? false;

  bool get isPatternsPage => id == "/patterns";

  bool get isNewEventPage => id == "/new-event";

  bool get isSettingsPage => id == "/settings";

  bool get isEventDetailsPage => id?.startsWith("/events/") ?? false;
}

class EventRouterDelegate extends RouterDelegate<EventRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<EventRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  String? _selectedCategory;
  Event? _selectedEvent;
  int _homePageNavigationItem = 0;
  bool _newEventNeeded = false;
  bool _show404 = false;

  EventRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: [
          MaterialPage(
            key: const ValueKey('/'),
            child: HomePage(
              selectedNavigationItem: _homePageNavigationItem,
              onNavigationItemTapped: (item) {
                _homePageNavigationItem = item;
                notifyListeners();
              },
              onEventTapped: (event) {
                _selectedEvent = event;
                notifyListeners();
              },
              onCategoryTapped: (string) {
                _selectedCategory = string;
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
                onSubmit: () {
                  _newEventNeeded = false;
                  notifyListeners();
                },
              ),
            )
          else if (_selectedCategory != null)
            MaterialPage(
              key: ValueKey('/events/${_selectedCategory ?? ""}'),
              child: CategoryDetailsPage(
                category: _selectedCategory!,
              ),
            )
          else if (_selectedEvent != null)
            MaterialPage(
              key: ValueKey('/events/${_selectedEvent?.id ?? ""}'),
              child: EventDetailsPage(
                event: _selectedEvent!,
                onDeleteEvent: () {
                  _selectedEvent = null;
                  notifyListeners();
                },
              ),
            ),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          _selectedEvent = null;
          _selectedCategory = null;
          _newEventNeeded = false;
          _show404 = false;
          notifyListeners();

          return true;
        },
      );

  @override
  Future<void> setNewRoutePath(EventRoutePath configuration) async {
    if (configuration.isUnknown) {
      _selectedCategory = null;
      _selectedEvent = null;
      _newEventNeeded = false;
      _show404 = true;
      return;
    }

    if (configuration.isEventDetailsPage) {
      if (configuration.id?.startsWith("/events/") ?? false) {
        final eventId = configuration.id?.replaceFirst("/events/", "");
        final container = ProviderContainer();
        final events = await container.read(eventProvider).list.last;
        _selectedEvent = events.firstWhere((element) => element.id == eventId);
      } else {
        _show404 = true;
        return;
      }
    } else if (configuration.isCategoryDetailsPage) {
      if (configuration.id?.startsWith("/categories/") ?? false) {
        final category = configuration.id?.replaceFirst("/categories/", "");
        _selectedCategory = category;
      } else {
        _show404 = true;
        return;
      }
    } else if (configuration.isNewEventPage) {
      _selectedCategory = null;
      _selectedEvent = null;
      _newEventNeeded = true;
    } else {
      if (configuration.isPatternsPage) {
        _homePageNavigationItem = 0;
      } else if (configuration.isSettingsPage) {
        _homePageNavigationItem = 2;
      } else if (configuration.isCategoriesPage) {
        _homePageNavigationItem = 3;
      } else {
        _homePageNavigationItem = 1;
      }
      _selectedCategory = null;
      _selectedEvent = null;
      _newEventNeeded = false;
    }

    _show404 = false;
  }

  @override
  EventRoutePath get currentConfiguration {
    if (_show404) {
      return const EventRoutePath.unknown();
    }

    if (_newEventNeeded) {
      return const EventRoutePath.newEvent();
    }

    if (_selectedCategory != null) {
      return EventRoutePath.categoryDetails(_selectedCategory);
    }

    return _selectedEvent == null ? const EventRoutePath.home() : EventRoutePath.eventDetails(_selectedEvent?.id);
  }
}

class EventRouteInformationParser extends RouteInformationParser<EventRoutePath> {
  @override
  Future<EventRoutePath> parseRouteInformation(RouteInformation? routeInformation) async {
    final uri = Uri.parse(routeInformation?.location ?? "/");

    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return const EventRoutePath.home();
    }

    // Handle '/patterns', '/new-event' '/events', '/settings', and '/categories'
    if (uri.pathSegments.length == 1) {
      if (uri.pathSegments[0] == 'patterns') {
        return const EventRoutePath.patterns();
      } else if (uri.pathSegments[0] == 'new-event') {
        return const EventRoutePath.newEvent();
      } else if (uri.pathSegments[0] == 'events') {
        return const EventRoutePath.home();
      } else if (uri.pathSegments[0] == 'settings') {
        return const EventRoutePath.settings();
      } else if (uri.pathSegments[0] == 'categories') {
        return const EventRoutePath.categories();
      } else {
        return const EventRoutePath.unknown();
      }
    }

    // Handle '/events/:id' and '/categories/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'events') {
        final remaining = uri.pathSegments[1];
        final id = remaining;
        // if (id == null) return EventRoutePath.unknown();
        return EventRoutePath.eventDetails(id);
      } else if (uri.pathSegments[0] == 'categories') {
        final remaining = uri.pathSegments[1];
        final id = remaining;
        // if (id == null) return EventRoutePath.unknown();
        return EventRoutePath.categoryDetails(id);
      }
      return const EventRoutePath.unknown();
    }

    // Handle unknown routes
    return const EventRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(EventRoutePath configuration) {
    if (configuration.isUnknown) {
      return const RouteInformation(location: '/404');
    } else if (configuration.isHomePage) {
      return const RouteInformation(location: '/');
    } else if (configuration.isPatternsPage) {
      return const RouteInformation(location: '/patterns');
    } else if (configuration.isNewEventPage) {
      return const RouteInformation(location: '/new-event');
    } else if (configuration.isSettingsPage) {
      return const RouteInformation(location: '/settings');
    } else if (configuration.isCategoriesPage) {
      return const RouteInformation(location: '/categories');
    } else if (configuration.isCategoryDetailsPage) {
      return RouteInformation(location: configuration.id);
    } else if (configuration.isEventDetailsPage) {
      return RouteInformation(location: configuration.id);
    }
    return null;
  }
}
