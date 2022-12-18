import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import '../components/events_index.dart';
import 'custom_scaffold.dart';

class EventsIndexPage extends StatelessWidget {
  final String? category;
  final bool withFloatingActionButton;

  const EventsIndexPage(
      {super.key, this.category, this.withFloatingActionButton = false});

  @override
  Widget build(BuildContext context) => CustomScaffold(
        appBarTitle:
            category == null ? "Events" : "Events for category '$category'",
        withFloatingActionButton: withFloatingActionButton,
        body: EventsIndex(
          withTitle: category,
          onEventTapped: (event) =>
              Routemaster.of(context).push('/events/${event.id}'),
        ),
      );
}
