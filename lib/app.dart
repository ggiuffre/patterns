import 'package:flutter/material.dart';

import 'ui/pages/routing.dart';

class PatternsApp extends StatefulWidget {
  @override
  _PatternsAppState createState() => _PatternsAppState();
}

class _PatternsAppState extends State<PatternsApp> {
  EventRouterDelegate _routerDelegate = EventRouterDelegate();
  EventRouteInformationParser _routeInformationParser = EventRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.brown,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      themeMode: ThemeMode.system,
      title: 'Patterns',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
