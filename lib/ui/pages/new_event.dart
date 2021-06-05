import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart';
import '../components/new_event_form.dart';

class NewEventPage extends StatelessWidget {
  final void Function() onSubmit;

  const NewEventPage({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          title: const Text("New event"),
          withLogoutAction: true,
        ),
        body: NewEventForm(onSubmit: onSubmit),
      );
}
