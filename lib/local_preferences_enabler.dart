import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/theme_mode_provider.dart';

class LocalPreferencesEnabler extends StatelessWidget {
  final Widget child;

  const LocalPreferencesEnabler({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: context.read(themeModeProvider.notifier).syncFromSharedPreferences(),
        builder: (_, __) => child,
      );
}
