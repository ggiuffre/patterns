import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_settings_provider.dart';

class LocalPreferencesEnabler extends ConsumerWidget {
  final Widget child;

  const LocalPreferencesEnabler({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
        future: ref.read(appSettingsProvider.notifier).syncFromSharedPreferences(),
        builder: (_, __) => child,
      );
}
