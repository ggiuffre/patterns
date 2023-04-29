import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../data/repositories/event_providers.dart';
import '../components/event_details.dart';
import 'custom_scaffold.dart';
import 'error.dart';

class EventDetailsPage extends ConsumerWidget {
  final String? eventId;

  const EventDetailsPage({super.key, this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(eventList)
      .whenData((value) => value.firstWhere((element) => element.id == eventId))
      .when(
        loading: () => const CustomScaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (error, stackTrace) => const ErrorPage(),
        data: (data) => EventDetails(
          event: data,
          onDeleteEvent: () => Routemaster.of(context).push('/events'),
        ),
      );
}
