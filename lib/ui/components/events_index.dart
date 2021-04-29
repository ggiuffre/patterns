import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/date_formatting.dart';
import '../../data/event.dart';

class EventsIndex extends ConsumerWidget {
  final void Function(Event) onEventTapped;
  final _user = FirebaseAuth.instance.currentUser;

  EventsIndex({Key? key, required this.onEventTapped}) : super(key: key);

  @override
  Widget build(context, watch) {
    // final events = watch(eventProvider).reversed.toList();
    return FutureBuilder<Iterable<Event>>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(_user?.uid)
            .collection("events")
            .get()
            .then((collection) => collection.docs.map((e) => Event.fromFirestore(e.data()["title"], e.data()["time"]))),
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
        });
  }
}
