import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/events.dart';
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
                      builder: (innerContext, watch, _) => Switch.adaptive(
                        value: _isDark(themeMode: watch(themeModeProvider), context: innerContext),
                        onChanged: (value) async =>
                            await innerContext.read(themeModeProvider.notifier).setDarkMode(value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.warning),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: const Text("Danger zone"),
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final shouldDeleteEvents = await showDialog<bool>(
                            context: context,
                            builder: (innerContext) => _DeleteAllEventsDialog(),
                          ) ??
                          false;
                      if (shouldDeleteEvents) {
                        final allEvents = await context.read(eventProvider).list;
                        for (final e in allEvents) {
                          await context.read(eventProvider).delete(e.id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All your events have been deleted 😅')),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    label: Text(
                      "Delete all events",
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  bool _isDark({required ThemeMode themeMode, required BuildContext context}) {
    if ({ThemeMode.light, ThemeMode.dark}.contains(themeMode)) {
      return themeMode == ThemeMode.dark;
    } else {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }
}

class _DeleteAllEventsDialog extends StatelessWidget {
  const _DeleteAllEventsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text("Confirmation"),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              'Delete all my events',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
}
