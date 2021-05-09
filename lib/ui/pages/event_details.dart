import 'package:flutter/material.dart';

import '../../data/event.dart';
import '../components/user_app_bar.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: UserAppBar(title: Text(event.title)),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${event.title}, on ${event.time}"),
        ),
      );
}
