import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_settings_provider.dart';
import 'theme.dart';
import 'ui/pages/routing.dart';

class PatternsApp extends ConsumerWidget {
  final EventRouterDelegate _routerDelegate = EventRouterDelegate();
  final EventRouteInformationParser _routeInformationParser = EventRouteInformationParser();

  @override
  Widget build(BuildContext context, watch) => MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: watch(appSettingsProvider).themeMode,
        title: 'Patterns',
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      );
}
