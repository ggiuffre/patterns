import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patterns/src/data/repositories/event_providers.dart';

import '../../data/date_formatting.dart';
import '../../data/event.dart';
import 'error_card.dart';

class EventsIndex extends ConsumerWidget {
  final void Function(Event) onEventTapped;
  final String? withTitle;

  const EventsIndex({Key? key, required this.onEventTapped, this.withTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(sortedEventList).when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, stackTrace) {
              developer.log(error.toString());
              return const ErrorCard(text: "Couldn't retrieve events.");
            },
            data: (data) {
              final events = (withTitle == null
                      ? data
                      : data.where((e) => e.title == withTitle))
                  .toList();
              return events.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("No events yet")),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: events.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (BuildContext context, int index) =>
                          ListTile(
                        title: Text(events[index].title),
                        onTap: () => onEventTapped(events[index]),
                        trailing: Text(formattedDate(events[index].start)),
                      ),
                    );
            },
          );
}
