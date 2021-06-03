import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart';

import '../../data/app_settings_provider.dart';
import '../../data/repositories/events.dart';
import 'constrained_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(8.0),
        children: const [
          DarkModeSettingsCard(),
          GoogleCalendarSettingsCard(),
          DangerZoneSettingsCard(),
        ],
      );
}

class DarkModeSettingsCard extends StatelessWidget {
  const DarkModeSettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dark mode"),
              Consumer(
                builder: (innerContext, watch, _) => Switch.adaptive(
                  value: _isDark(themeMode: watch(appSettingsProvider).themeMode, context: innerContext),
                  onChanged: (value) async => await innerContext.read(appSettingsProvider.notifier).setDarkMode(value),
                ),
              ),
            ],
          ),
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

class GoogleCalendarSettingsCard extends StatelessWidget {
  const GoogleCalendarSettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Allow to see my Google Calendar events"),
                Consumer(
                  builder: (innerContext, watch, _) => Switch.adaptive(
                    value: watch(appSettingsProvider).google.enabled,
                    onChanged: (newValue) async {
                      if (newValue) {
                        print("Attempting to sign in to a Google account...");
                        await innerContext.read(appSettingsProvider.notifier).signInToGoogle();
                        final currentUser = innerContext.read(appSettingsProvider).google.account;
                        print("Signed in to ${currentUser?.displayName}'s Google Calendar");
                        await currentUser?.authHeaders
                            .then((headers) => innerContext.read(googleCalendarEventProvider).enable(headers));
                        final someEvents = await innerContext.read(googleCalendarEventProvider).list.first;
                        print(someEvents.map((e) => "${e.title} on ${e.time}"));
                      } else {
                        print("Attempting to sign out of a Google account...");
                        innerContext.read(googleCalendarEventProvider).disable();
                        await innerContext.read(appSettingsProvider.notifier).signOutOfGoogle();
                        print("Signed out.");
                      }
                    },
                  ),
                ),
              ],
            ),
            Consumer(builder: (innerContext, watch, _) {
              return watch(appSettingsProvider).google.enabled
                  ? FutureBuilder<Iterable<CalendarListEntry>>(
                      future: innerContext.read(appSettingsProvider.notifier).googleCalendars,
                      builder: (context, snapshot) {
                        final errorIndicator = Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Theme.of(context).errorColor),
                              const Flexible(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Couldn't retrieve your list of calendars from Google Calendar."),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (snapshot.hasError) {
                          return errorIndicator;
                        }

                        if (snapshot.hasData) {
                          final calendarSwitches = snapshot.data
                                  ?.map(
                                    (calendar) => Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(calendar.summary ?? "untitled"),
                                        Switch.adaptive(
                                          value: watch(appSettingsProvider)
                                              .google
                                              .enabledCalendarIds
                                              .contains(calendar.id),
                                          onChanged: (newValue) => innerContext
                                              .read(appSettingsProvider.notifier)
                                              .setGoogleCalendarImportance(calendar, newValue),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList() ??
                              [];
                          if (calendarSwitches.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text("Read (or ignore) events from my calendars:"),
                                  ),
                                  ...calendarSwitches
                                ],
                              ),
                            );
                          } else {
                            return errorIndicator;
                          }
                        }

                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        );
                      },
                    )
                  : Container();
            }),
          ],
        ),
      ),
    );
  }
}

class DangerZoneSettingsCard extends StatelessWidget {
  const DangerZoneSettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedCard(
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
      );
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
