import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/event_provider.dart';

class EventsIndex extends ConsumerWidget {
  final void Function(Event) onEventTapped;

  const EventsIndex({Key? key, required this.onEventTapped}) : super(key: key);

  @override
  Widget build(context, watch) {
    final events = watch(eventProvider).reversed.toList();
    return events.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text("No events to display yet")),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: events.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) => ListTile(
              title: Text(events[index].title),
              onTap: () => onEventTapped(events[index]),
              trailing: Text(events[index].time.toString()),
            ),
          );
  }
}
