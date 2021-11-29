import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_settings_provider.dart';
import 'theme.dart';
import 'ui/pages/routing.dart';

class PatternsApp extends ConsumerWidget {
  final EventRouterDelegate _routerDelegate = EventRouterDelegate();
  final EventRouteInformationParser _routeInformationParser = EventRouteInformationParser();

  PatternsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ref.watch(appSettingsProvider).themeMode,
        title: 'Patterns',
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      );
}
