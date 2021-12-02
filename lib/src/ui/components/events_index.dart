import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/date_formatting.dart';
import '../../data/event.dart';
import '../../data/repositories/events.dart';
import 'error_card.dart';

class EventsIndex extends ConsumerWidget {
  final void Function(Event) onEventTapped;
  final String? withTitle;

  const EventsIndex({Key? key, required this.onEventTapped, this.withTitle}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => StreamBuilder<Iterable<Event>>(
        stream: ref.read(eventProvider).sorted(descending: true),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorCard(text: "Couldn't retrieve events.");
          }

          if (snapshot.hasData) {
            final events =
                (withTitle == null ? snapshot.data : snapshot.data?.where((e) => e.title == withTitle))?.toList() ?? [];
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
                      trailing: Text(formattedDate(events[index].start)),
                    ),
                  );
          }

          return const Center(child: CircularProgressIndicator.adaptive());
        },
      );
}
