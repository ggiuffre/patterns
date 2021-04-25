import 'package:flutter/material.dart';

import 'ui/pages/routing.dart';

class PatternsApp extends StatelessWidget {
  final EventRouterDelegate _routerDelegate = EventRouterDelegate();
  final EventRouteInformationParser _routeInformationParser = EventRouteInformationParser();

  final ThemeData theme;
  final ThemeData darkTheme;

  PatternsApp({Key? key, required this.theme, required this.darkTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        theme: theme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        title: 'Patterns',
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      );
}
