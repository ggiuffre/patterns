import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/event_provider.dart';

class EventsIndexPage extends StatelessWidget {
  final void Function(Event) onEventTapped;
  final VoidCallback onNewEvent;

  const EventsIndexPage({
    Key? key,
    required this.onEventTapped,
    required this.onNewEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
        ),
        body: Consumer(
          builder: (context, watch, child) {
            final events = watch(eventProvider);
            return events.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text("Nothing to display")),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: events.length,
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (BuildContext context, int index) => ListTile(
                      title: Text(events[index].title),
                      onTap: () => onEventTapped(events[index]),
                    ),
                  );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onNewEvent,
          tooltip: 'New event',
          child: const Icon(Icons.add),
        ),
      );
}
