import 'package:flutter/material.dart';

import '../components/new_event_form.dart';
import '../components/user_app_bar.dart';

class NewEventPage extends StatelessWidget {
  final void Function() onSubmit;

  const NewEventPage({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: UserAppBar(
          title: const Text("New event"),
        ),
        body: NewEventForm(onSubmit: onSubmit),
      );
}
