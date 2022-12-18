import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import '../components/event_details.dart';
import 'custom_scaffold.dart';
import 'error.dart';

class EventDetailsPage extends ConsumerWidget {
  final String? eventId;

  const EventDetailsPage({super.key, this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) => eventId == null
      ? const ErrorPage()
      : FutureBuilder<Event>(
          future: ref.read(eventProvider).get(eventId!),
          builder: (context, snapshot) => snapshot.data != null
              ? EventDetails(
                  event: snapshot.data!,
                  onDeleteEvent: () => Routemaster.of(context).push('/events'),
                )
              : const CustomScaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()),
                ),
        );
}
