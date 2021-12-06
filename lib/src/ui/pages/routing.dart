import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import '../components/custom_app_bar.dart';
import '../components/events_index.dart';
import 'category_details.dart';
import 'error.dart';
import 'event_details.dart';
import 'home.dart';
import 'new_event.dart';

class AppRoutePath {
  final String? id;
  final bool isUnknown;

  const AppRoutePath.home()
      : id = "/",
        isUnknown = false;

  const AppRoutePath.categories()
      : id = "/categories",
        isUnknown = false;

  const AppRoutePath.patterns()
      : id = "/patterns",
        isUnknown = false;

  const AppRoutePath.categoryDetails(title)
      : id = "/categories/$title",
        isUnknown = false;

  const AppRoutePath.categoryEvents(title)
      : id = "/categories/$title/events",
        isUnknown = false;

  const AppRoutePath.eventDetails(eventId)
      : id = "/events/$eventId",
        isUnknown = false;

  const AppRoutePath.newEvent()
      : id = "/new-event",
        isUnknown = false;

  const AppRoutePath.settings()
      : id = "/settings",
        isUnknown = false;

  const AppRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == "/";

  bool get isCategoriesPage => id == "/categories";

  bool get isCategoryDetailsPage {
    final pathSegments = Uri.parse(id ?? "").pathSegments;
    return pathSegments.first == "categories" && pathSegments.length == 2 && pathSegments[1] != "";
  }

  bool get isCategoryEventsPage {
    final pathSegments = Uri.parse(id ?? "").pathSegments;
    return pathSegments.first == "categories" &&
        pathSegments.length == 3 &&
        pathSegments[1] != "" &&
        pathSegments[2] == "events";
  }

  bool get isPatternsPage => id == "/patterns";

  bool get isNewEventPage => id == "/new-event";

  bool get isSettingsPage => id == "/settings";

  bool get isEventDetailsPage {
    final pathSegments = Uri.parse(id ?? "").pathSegments;
    return pathSegments.length == 2 && pathSegments.first == "events" && pathSegments[1] != "";
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  String? _selectedCategory;
  Event? _selectedEvent;
  int _homePageNavigationItem = 0;
  bool _newEventNeeded = false;
  bool _show404 = false;
  bool _showCategoryEvents = false;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

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
          else if (_selectedCategory != null && _showCategoryEvents)
            MaterialPage(
              key: ValueKey('/category/$_selectedCategory/events'),
              child: Scaffold(
                appBar: CustomAppBar(
                  title: Text("Events for category '$_selectedCategory'"),
                  withLogoutAction: true,
                ),
                body: EventsIndex(
                    onEventTapped: (event) {
                      _selectedEvent = event;
                      notifyListeners();
                    },
                    withTitle: _selectedCategory),
              ),
            )
          else if (_selectedCategory != null)
            MaterialPage(
              key: ValueKey('/category/$_selectedCategory'),
              child: CategoryDetailsPage(
                category: _selectedCategory!,
                onCategoryEventsTapped: () {
                  _showCategoryEvents = true;
                  notifyListeners();
                },
              ),
            )
          else if (_selectedEvent != null)
            MaterialPage(
              key: ValueKey('/events/$_selectedEvent'),
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
          _showCategoryEvents = false;
          notifyListeners();

          return true;
        },
      );

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    if (configuration.isUnknown) {
      _selectedCategory = null;
      _selectedEvent = null;
      _newEventNeeded = false;
      _show404 = true;
      _showCategoryEvents = false;
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
    } else if (configuration.isCategoryEventsPage) {
      if (configuration.id?.startsWith("/categories/") ?? false) {
        final category = configuration.id?.replaceFirst("/categories/", "").replaceFirst("/events", "");
        _selectedCategory = category;
        _showCategoryEvents = true;
      } else {
        _show404 = true;
        return;
      }
    } else if (configuration.isNewEventPage) {
      _selectedCategory = null;
      _selectedEvent = null;
      _newEventNeeded = true;
      _showCategoryEvents = false;
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
      _showCategoryEvents = false;
    }

    _show404 = false;
  }

  @override
  AppRoutePath get currentConfiguration {
    if (_show404) {
      return const AppRoutePath.unknown();
    }

    if (_newEventNeeded) {
      return const AppRoutePath.newEvent();
    }

    if (_selectedCategory != null) {
      if (_showCategoryEvents) {
        return AppRoutePath.categoryEvents(_selectedCategory);
      }

      return AppRoutePath.categoryDetails(_selectedCategory);
    }

    return _selectedEvent == null ? const AppRoutePath.home() : AppRoutePath.eventDetails(_selectedEvent?.id);
  }
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(RouteInformation? routeInformation) async {
    final uri = Uri.parse(routeInformation?.location ?? "/");

    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return const AppRoutePath.home();
    }

    // Handle '/patterns', '/new-event' '/events', '/settings', and '/categories'
    if (uri.pathSegments.length == 1) {
      if (uri.pathSegments[0] == 'patterns') {
        return const AppRoutePath.patterns();
      } else if (uri.pathSegments[0] == 'new-event') {
        return const AppRoutePath.newEvent();
      } else if (uri.pathSegments[0] == 'events') {
        return const AppRoutePath.home();
      } else if (uri.pathSegments[0] == 'settings') {
        return const AppRoutePath.settings();
      } else if (uri.pathSegments[0] == 'categories') {
        return const AppRoutePath.categories();
      }
    }

    // Handle '/events/:id' and '/categories/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'events') {
        final id = uri.pathSegments[1];
        // if (id == null) return EventRoutePath.unknown();
        return AppRoutePath.eventDetails(id);
      } else if (uri.pathSegments[0] == 'categories') {
        final id = uri.pathSegments[1];
        // if (id == null) return EventRoutePath.unknown();
        return AppRoutePath.categoryDetails(id);
      }
    }

    // Handle '/categories/:id/events'
    if (uri.pathSegments.length == 3) {
      if (uri.pathSegments[0] == 'categories') {
        final id = uri.pathSegments[1];
        // if (id == null) return EventRoutePath.unknown();
        if (uri.pathSegments[2] == 'events') {
          return AppRoutePath.categoryEvents(id);
        }
      }
    }

    // Handle remaining (unknown) routes
    return const AppRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
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
      return RouteInformation(location: '/categories/${configuration.id}');
    } else if (configuration.isCategoryEventsPage) {
      return RouteInformation(location: '/categories/${configuration.id}/events');
    } else if (configuration.isEventDetailsPage) {
      return RouteInformation(location: '/events/${configuration.id}');
    }
    return null;
  }
}
