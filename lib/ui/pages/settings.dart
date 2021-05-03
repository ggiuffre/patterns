import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_mode_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
                    const Text("Dark mode"),
                    Consumer(
                      builder: (context, watch, _) => Switch.adaptive(
                        value: watch(themeModeProvider) == ThemeMode.dark,
                        onChanged: (_) => context.read(themeModeProvider.notifier).toggle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
