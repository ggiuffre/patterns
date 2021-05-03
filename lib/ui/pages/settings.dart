import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_mode_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Brightness"),
                    Switch.adaptive(
                      value: context.read(themeModeProvider.notifier).light,
                      onChanged: (_) => context.read(themeModeProvider.notifier).toggle(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
