import 'package:flutter/material.dart';
import 'package:patterns/ui/components/new_event_form.dart';

class NewEventPage extends StatelessWidget {
  final void Function() onSubmit;

  const NewEventPage({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("New event"),
        ),
        body: NewEventForm(onSubmit: onSubmit),
      );
}
