import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import '../components/custom_app_bar.dart';
import '../components/new_event_form.dart';

class NewEventPage extends StatelessWidget {
  const NewEventPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Routemaster.of(context)
                .push('/events'), // TODO why doesn't pop work?
          ),
          title: const Text("New event"),
          withLogoutAction: true,
        ),
        body: NewEventForm(
          onSubmit: () => Routemaster.of(context).push('/events'),
        ),
      );
}
