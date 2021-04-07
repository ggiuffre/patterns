import 'package:flutter/material.dart';

import '../../data/event.dart';

class EventsIndexPage extends StatelessWidget {
  final List<Event> events;
  final void Function(Event) onEventTapped;
  final VoidCallback onNewEvent;

  const EventsIndexPage({
    Key? key,
    this.events = const <Event>[],
    required this.onEventTapped,
    required this.onNewEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
        ),
        body: events.isEmpty
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
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: onNewEvent,
          tooltip: 'New event',
          child: Icon(Icons.add),
        ),
      );
}
