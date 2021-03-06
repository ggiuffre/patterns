import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as g;

import '../../data/app_settings_provider.dart';
import '../../data/event.dart';
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
          BodyWeightSettingsCard(),
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
                builder: (innerContext, ref, _) => Switch.adaptive(
                  value: _isDark(themeMode: ref.watch(appSettingsProvider).themeMode, context: innerContext),
                  onChanged: (value) async => await ref.read(appSettingsProvider.notifier).setDarkMode(value),
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

class GoogleCalendarSettingsCard extends ConsumerWidget {
  const GoogleCalendarSettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => ConstrainedCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Allow to see my Google Calendar events"),
                  Switch.adaptive(
                    value: ref.watch(appSettingsProvider).google.enabled,
                    onChanged: (newValue) async {
                      if (newValue) {
                        await ref.read(appSettingsProvider.notifier).signInToGoogle();
                      } else {
                        await ref.read(appSettingsProvider.notifier).signOutOfGoogle();
                      }
                    },
                  ),
                ],
              ),
              if (ref.watch(appSettingsProvider).google.enabled)
                FutureBuilder<Iterable<g.CalendarListEntry>>(
                  future: ref.read(appSettingsProvider.notifier).googleCalendars,
                  builder: (context, snapshot) {
                    final errorIndicator = Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                    Expanded(
                                      child: Text(_calendarEntryTitle(calendar), overflow: TextOverflow.ellipsis),
                                    ),
                                    Switch.adaptive(
                                      value: ref
                                          .watch(appSettingsProvider)
                                          .google
                                          .enabledCalendarIds
                                          .contains(calendar.id),
                                      onChanged: (newValue) => ref
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
                ),
            ],
          ),
        ),
      );

  String _calendarEntryTitle(g.CalendarListEntry calendar) {
    final isPrimary = calendar.primary ?? false;
    final calendarSummary = calendar.summary;
    if (calendarSummary != null) {
      // TODO remove soft hyphens once Flutter allows to specify word hyphenation
      return isPrimary ? "Primary calendar (${calendarSummary.split('').join('\u00ad')})" : calendarSummary;
    } else {
      return "Untitled";
    }
  }
}

class DangerZoneSettingsCard extends ConsumerWidget {
  const DangerZoneSettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => ConstrainedCard(
        child: ExpansionTile(
          leading: const Icon(Icons.warning),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: const Text("Danger zone"),
          children: [
            TextButton.icon(
              onPressed: () async {
                final shouldDeleteEvents = await showDialog<bool>(
                      context: context,
                      builder: (innerContext) => const _DeleteAllEventsDialog(),
                    ) ??
                    false;
                if (shouldDeleteEvents) {
                  final allEvents = await ref.read(eventProvider).list.last;
                  for (final e in allEvents) {
                    await ref.read(eventProvider).delete(e.id);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All your events have been deleted ????')),
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
            child: const Text('Cancel'),
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

class BodyWeightSettingsCard extends ConsumerStatefulWidget {
  const BodyWeightSettingsCard({Key? key}) : super(key: key);

  @override
  ConsumerState<BodyWeightSettingsCard> createState() => _BodyWeightSettingsCardState();
}

class _BodyWeightSettingsCardState extends ConsumerState<BodyWeightSettingsCard> {
  final _formKey = GlobalKey<FormState>();
  double? _newBodyWeight;
  bool _addingEvent = false;

  @override
  Widget build(BuildContext context) => ConstrainedCard(
        child: FutureBuilder<Iterable<Event>>(
          future: ref
              .read(eventProvider)
              .sorted()
              .last
              .then((events) => events.where((e) => e.title == "weight measurement")),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.warning, color: Theme.of(context).errorColor),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Couldn't retrieve body weight from events"),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasData) {
              return Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Body weight"),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: (snapshot.data?.isEmpty ?? true)
                              ? null
                              : snapshot.data?.last.value.toStringAsPrecision(2),
                          decoration: const InputDecoration(suffixText: "Kg"),
                          onChanged: (value) => setState(() => _newBodyWeight = double.tryParse(value)),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your current weight';
                            } else if (double.tryParse(value ?? "") == null) {
                              return 'Please enter a valid numeric value for your weight';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _addingEvent
                          ? const Center(child: CircularProgressIndicator.adaptive())
                          : ActionChip(label: const Text("Update"), onPressed: _onSubmit),
                    ),
                  ],
                ),
              );
            }

            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          },
        ),
      );

  Future<void> _onSubmit() async {
    final formState = _formKey.currentState;
    if (formState != null) {
      if (formState.validate()) {
        setState(() => _addingEvent = true);
        final newBodyWeight = _newBodyWeight;
        if (newBodyWeight != null) {
          final _now = DateTime.now();
          final _today = DateTime(_now.year, _now.month, _now.day);
          final event = Event("weight measurement", value: newBodyWeight, start: _today);
          await ref.read(eventProvider).add(event);
          setState(() => _addingEvent = false);
        }
      }
    }
  }
}
