import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/date_formatting.dart';
import '../../data/event.dart';
import '../../data/repositories/events.dart';

class EventsIndex extends ConsumerWidget {
  final void Function(Event) onEventTapped;

  const EventsIndex({Key? key, required this.onEventTapped}) : super(key: key);

  @override
  Widget build(context, watch) => FutureBuilder<Iterable<Event>>(
        future: context.read(eventProvider).sorted,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Couldn't retrieve events."));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            final events = snapshot.data?.toList() ?? [];
            return events.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text("No events yet")),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: events.length,
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (BuildContext context, int index) => ListTile(
                      title: Text(events[index].title),
                      onTap: () => onEventTapped(events[index]),
                      trailing: Text(formattedDate(events[index].time)),
                    ),
                  );
          }

          return const Center(child: CircularProgressIndicator.adaptive());
        },
      );
}
