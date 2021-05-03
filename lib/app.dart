import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patterns/data/theme_mode_provider.dart';

import 'theme.dart';
import 'ui/pages/routing.dart';

class PatternsApp extends StatelessWidget {
  final EventRouterDelegate _routerDelegate = EventRouterDelegate();
  final EventRouteInformationParser _routeInformationParser = EventRouteInformationParser();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: context.read(themeModeProvider),
        title: 'Patterns',
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      );
}
