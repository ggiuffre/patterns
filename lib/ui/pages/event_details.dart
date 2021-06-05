import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import '../components/constrained_card.dart';
import '../components/custom_app_bar.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;
  final void Function() onDeleteEvent;

  const EventDetailsPage({Key? key, required this.event, required this.onDeleteEvent}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(title: Text(event.title), withLogoutAction: true),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            ConstrainedCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${event.title}, on ${event.time}"),
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
                      await context.read(eventProvider).delete(event.id);
                      onDeleteEvent();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).errorColor,
                    ),
                    label: Text(
                      "Delete this event",
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).errorColor),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final allEvents = await context.read(eventProvider).list.first;
                      final eventsInCategory = allEvents.where((e) => e.title == event.title);
                      for (final e in eventsInCategory) {
                        await context.read(eventProvider).delete(e.id);
                      }
                      onDeleteEvent();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).errorColor,
                    ),
                    label: Text(
                      "Delete all events with this title",
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).errorColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
