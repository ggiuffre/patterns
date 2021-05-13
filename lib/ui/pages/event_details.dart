import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patterns/data/repositories/events.dart';

import '../../data/event.dart';
import '../components/user_app_bar.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;
  final void Function() onDeleteEvent;

  const EventDetailsPage({Key? key, required this.event, required this.onDeleteEvent}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: UserAppBar(title: Text(event.title)),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${event.title}, on ${event.time}"),
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
                        await context.read(eventProvider).delete(event.id);
                        onDeleteEvent();
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      label: Text(
                        "Delete this event",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final allEvents = await context.read(eventProvider).list;
                        final eventsInCategory = allEvents.where((e) => e.title == event.title);
                        for (final e in eventsInCategory) {
                          await context.read(eventProvider).delete(e.id);
                        }
                        onDeleteEvent();
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      label: Text(
                        "Delete all events with this title",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
