import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/calendar/v3.dart' as g;
import 'package:patterns/src/data/repositories/event_providers.dart';

import '../../data/google_data_provider.dart';
import '../../data/event.dart';
import '../../data/repositories/events.dart';
import '../../data/theme_mode_provider.dart';
import 'constrained_card.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

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

class DarkModeSettingsCard extends ConsumerWidget {
  const DarkModeSettingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => ConstrainedCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ref.watch(themeModeProvider).when(
                data: (themeMode) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dark mode"),
                    Switch.adaptive(
                      value: _isDark(themeMode: themeMode, context: context),
                      onChanged: (value) async => await ref
                          .read(themeModeProvider.notifier)
                          .setDarkMode(value),
                    ),
                  ],
                ),
                loading: () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dark mode"),
                    Switch.adaptive(
                      value: _isDark(
                          themeMode: ThemeMode.system, context: context),
                      onChanged: null,
                    ),
                  ],
                ),
                error: (Object error, StackTrace stackTrace) => _ErrorNotice(
                  "Couldn't retrieve theme mode.",
                  error: error,
                  stackTrace: stackTrace,
                ),
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
          child: ref.watch(googleDataProvider).when(
                error: (Object error, StackTrace stackTrace) => Column(
                  children: [
                    const Text("Allow to see my Google Calendar events"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _ErrorNotice(
                        "Couldn't retrieve Google settings.",
                        error: error,
                        stackTrace: stackTrace,
                      ),
                    ),
                  ],
                ),
                loading: () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Allow to see my Google Calendar events"),
                    CircularProgressIndicator.adaptive(),
                  ],
                ),
                data: (value) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Allow to see my Google Calendar events"),
                        Switch.adaptive(
                          value: value.enabled,
                          onChanged: (newValue) async {
                            if (newValue) {
                              await ref
                                  .read(googleDataProvider.notifier)
                                  .signInToGoogle();
                            } else {
                              await ref
                                  .read(googleDataProvider.notifier)
                                  .signOutOfGoogle();
                            }
                          },
                        ),
                      ],
                    ),
                    if (value.enabled)
                      FutureBuilder<Iterable<g.CalendarListEntry>>(
                        future: value.calendars,
                        builder: (context, snapshot) {
                          const errorIndicator = Padding(
                            padding: EdgeInsets.all(8.0),
                            child: _ErrorNotice(
                                "Couldn't retrieve your list of calendars from Google Calendar."),
                          );

                          if (snapshot.hasError) {
                            return errorIndicator;
                          }

                          if (snapshot.hasData) {
                            final calendarSwitches = snapshot.data
                                    ?.map(
                                      (calendar) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                                _calendarEntryTitle(calendar),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Switch.adaptive(
                                            value: value.enabledCalendarIds
                                                .contains(calendar.id),
                                            onChanged: (newValue) => ref
                                                .read(
                                                    googleDataProvider.notifier)
                                                .setGoogleCalendarImportance(
                                                    calendar, newValue),
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                          "Read (or ignore) events from my calendars:"),
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
                            child: Center(
                                child: CircularProgressIndicator.adaptive()),
                          );
                        },
                      ),
                  ],
                ),
              ),
        ),
      );

  String _calendarEntryTitle(g.CalendarListEntry calendar) {
    final isPrimary = calendar.primary ?? false;
    final calendarSummary = calendar.summary;
    if (calendarSummary != null) {
      // TODO remove soft hyphens once Flutter allows to specify word hyphenation
      return isPrimary
          ? "Primary calendar (${calendarSummary.split('').join('\u00ad')})"
          : calendarSummary;
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
                  ref.read(eventList).value?.forEach((e) async =>
                      await ref.read(writableEventProvider).delete(e.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('All your events have been deleted 😅')),
                  );
                }
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                "Delete all events",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
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
        content: const Text(
            "This will permanently delete all the events that you entered, "
            "and all the patterns calculated from those events."),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(
              'Delete all my events',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
}

class BodyWeightSettingsCard extends ConsumerStatefulWidget {
  const BodyWeightSettingsCard({Key? key}) : super(key: key);

  @override
  ConsumerState<BodyWeightSettingsCard> createState() =>
      _BodyWeightSettingsCardState();
}

class _BodyWeightSettingsCardState
    extends ConsumerState<BodyWeightSettingsCard> {
  final _formKey = GlobalKey<FormState>();
  double? _newBodyWeight;
  bool _addingEvent = false;

  @override
  Widget build(BuildContext context) => ConstrainedCard(
        child: ref.watch(sortedEventList).when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.warning,
                          color: Theme.of(context).colorScheme.error),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Couldn't retrieve body weight from events"),
                    ),
                  ],
                ),
              ),
              data: (data) {
                final events =
                    data.where((e) => e.title == "weight measurement");
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
                            initialValue: (events.isEmpty)
                                ? null
                                : events.first.value.toStringAsPrecision(2),
                            decoration: const InputDecoration(suffixText: "Kg"),
                            onChanged: (value) => setState(
                                () => _newBodyWeight = double.tryParse(value)),
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
                            ? const Center(
                                child: CircularProgressIndicator.adaptive())
                            : ActionChip(
                                label: const Text("Update"),
                                onPressed: _onSubmit),
                      ),
                    ],
                  ),
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
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final event =
              Event("weight measurement", value: newBodyWeight, start: today);
          await ref.read(writableEventProvider).add(event);
          setState(() => _addingEvent = false);
        }
      }
    }
  }
}

class _ErrorNotice extends StatelessWidget {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const _ErrorNotice(this.message, {this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    dev.log(message, error: error, stackTrace: stackTrace);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Theme.of(context).colorScheme.error),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message),
          ),
        ),
      ],
    );
  }
}
