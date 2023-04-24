import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import 'authentication.dart';
import 'data/theme_mode_provider.dart';
import 'theme.dart';
import 'ui/pages/categories.dart';
import 'ui/pages/category_details.dart';
import 'ui/pages/event_details.dart';
import 'ui/pages/events.dart';
import 'ui/pages/new_event.dart';
import 'ui/pages/patterns.dart';
import 'ui/pages/settings.dart';

class PatternsApp extends ConsumerWidget {
  const PatternsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedOutMap = RouteMap(
      onUnknownRoute: (_) => const Redirect('/'),
      routes: {
        '/': (_) => const MaterialPage(child: SignUpLogInSelector()),
      },
    );

    final loggedInMap = RouteMap(
      routes: {
        '/': (_) => const Redirect('/events'),
        '/events': (_) => const MaterialPage(
              child: EventsIndexPage(withFloatingActionButton: true),
            ),
        '/categories': (_) => const MaterialPage(child: CategoriesIndexPage()),
        '/patterns': (_) => const MaterialPage(child: PatternsIndexPage()),
        '/categories/:id': (r) => MaterialPage(
              child: CategoryDetailsPage(
                category: Uri.decodeComponent(r.pathParameters['id'] ?? ''),
              ),
            ),
        '/categories/:id/events': (r) => MaterialPage(
              child: EventsIndexPage(
                category: Uri.decodeComponent(r.pathParameters['id'] ?? ''),
              ),
            ),
        '/events/:id': (r) => MaterialPage(
              child: EventDetailsPage(
                eventId: Uri.decodeComponent(r.pathParameters['id'] ?? ''),
              ),
            ),
        '/new-event': (_) => const MaterialPage(child: NewEventPage()),
        '/settings': (_) => const MaterialPage(child: SettingsPage()),
      },
    );

    const routeInformationParser = RoutemasterParser();
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) => snapshot.data == null
          ? MaterialApp.router(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ref.watch(themeModeProvider).value,
              title: 'Patterns',
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) => loggedOutMap,
              ),
              routeInformationParser: routeInformationParser,
            )
          : MaterialApp.router(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ref.watch(themeModeProvider).value,
              title: 'Patterns',
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) => loggedInMap,
              ),
              routeInformationParser: routeInformationParser,
            ),
    );
  }
}
