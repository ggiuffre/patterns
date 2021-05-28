import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patterns/data/google_account_provider.dart';

import '../../data/repositories/events.dart';
import '../../data/theme_mode_provider.dart';
import 'constrained_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          ConstrainedCard(
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
          ConstrainedCard(
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
                      final allEvents = await context.read(eventProvider).list.first;
                      for (final e in allEvents) {
                        await context.read(eventProvider).delete(e.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All your events have been deleted 😅')),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                  label: Text(
                    "Delete all events",
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).errorColor),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedCard(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Allow to see my Google Calendar events"),
                  Consumer(
                    builder: (innerContext, watch, _) => Switch.adaptive(
                      value: watch(googleAccountProvider),
                      onChanged: (newValue) async {
                        if (newValue) {
                          print("Attempting to sign in to a Google account...");
                          await innerContext.read(googleAccountProvider.notifier).signIn();
                          final currentUser = innerContext.read(googleAccountProvider.notifier).currentUser;
                          print("Signed in to ${currentUser?.displayName}'s Google Calendar");
                          final someEvents = await innerContext
                              .read(googleCalendarEventProvider.future)
                              .then((provider) => provider.list.first);
                          print(someEvents);
                        } else {
                          print("Attempting to sign out of a Google account...");
                          await innerContext.read(googleAccountProvider.notifier).signOut();
                          print("Signed out.");
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        content: const Text("This will permanently delete all the events that you entered, "
            "and all the patterns calculated from those events."),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              'Delete all my events',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).errorColor),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
}
