import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import 'constrained_card.dart';
import 'custom_app_bar.dart';

class EventDetails extends ConsumerWidget {
  final Event event;
  final void Function() onDeleteEvent;

  const EventDetails({
    Key? key,
    required this.event,
    required this.onDeleteEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: CustomAppBar(title: Text(event.title), withLogoutAction: true),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            ConstrainedCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${event.title}, on ${event.start}"),
              ),
            ),
            ConstrainedCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("value: ${event.value}"),
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
                      await ref.read(eventProvider).delete(event.id);
                      onDeleteEvent();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      "Delete this event",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final allEvents = await ref.read(eventProvider).list;
                      final eventsInCategory =
                          allEvents.where((e) => e.title == event.title);
                      for (final e in eventsInCategory) {
                        await ref.read(eventProvider).delete(e.id);
                      }
                      onDeleteEvent();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      "Delete all events with this title",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
