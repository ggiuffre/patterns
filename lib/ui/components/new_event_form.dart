import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import 'constrained_card.dart';

class NewEventForm extends StatefulWidget {
  final void Function() onSubmit;

  const NewEventForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _NewEventFormState createState() => _NewEventFormState();
}

class _NewEventFormState extends State<NewEventForm> {
  static const _frequencies = {
    Frequency.once: "Does not repeat",
    Frequency.daily: "Every day",
    Frequency.weekly: "Every week",
    Frequency.biWeekly: "Every other week",
    Frequency.monthly: "Every month",
    Frequency.biMonthly: "Every other month",
    Frequency.annually: "Every year",
  };

  final _formKey = GlobalKey<FormState>();
  final _dateFieldController = TextEditingController();

  String _eventTitle = "";
  DateTime _eventTime = DateTime.now();
  Frequency _eventFrequency = Frequency.once; // frequency with which the event being created occurs
  bool _addingEvent = false; // whether an event is in the process of being added

  @override
  void initState() {
    super.initState();
    _dateFieldController.text = _eventTime.toString();
  }

  @override
  void dispose() {
    _dateFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            ConstrainedCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Event title", style: Theme.of(context).textTheme.headline5),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _EventTitleTextField(
                        onHintSelected: (selection) => setState(() => _eventTitle = selection),
                        onFieldChanged: (newTitle) => setState(() => _eventTitle = newTitle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ConstrainedCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Event time", style: Theme.of(context).textTheme.headline5),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: _dateFieldController,
                        onTap: () async {
                          final newTime = await _selectDate(context);
                          setState(() => _eventTime = newTime);
                          _dateFieldController.text = newTime.toString();
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          labelText: 'Event time',
                        ),
                      ),
                    ),
                    ExpansionTile(
                      leading: const Icon(Icons.repeat),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Text(_frequencies[_eventFrequency]!),
                      children: [
                        for (final frequency in Frequency.values)
                          RadioListTile<Frequency>(
                            title: Text(_frequencies[frequency]!),
                            value: frequency,
                            groupValue: _eventFrequency,
                            onChanged: (v) => setState(() => _eventFrequency = v ?? _eventFrequency),
                            dense: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680.0),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _addingEvent
                      ? const Center(child: CircularProgressIndicator.adaptive())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitEvent,
                            child: const Text("Submit"),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );

  Future<DateTime> _selectDate(BuildContext context) async {
    final newTime = await showDatePicker(
      context: context,
      initialDate: _eventTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    return (newTime != _eventTime ? newTime : _eventTime) ?? _eventTime;
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _addingEvent = true);
      if (_eventFrequency != Frequency.once) {
        final events = eventsAtInterval(
          title: _eventTitle,
          range: DateTimeRange(start: _eventTime, end: _eventTime.add(const Duration(days: 90))),
          frequency: _eventFrequency,
        );
        for (final event in events) {
          context.read(eventProvider).add(event);
        }
      } else {
        await context.read(eventProvider).add(Event(_eventTitle, _eventTime));
      }
      widget.onSubmit();
    }
  }
}

class _EventTitleTextField extends StatelessWidget {
  final void Function(String) onHintSelected;
  final void Function(String) onFieldChanged;

  const _EventTitleTextField({
    Key? key,
    required this.onHintSelected,
    required this.onFieldChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<Set<String>>(
        future: context.read(eventProvider).list.last.then((events) => events.map((e) => e.title).toSet()),
        builder: (context, snapshot) {
          final hints = (snapshot.connectionState == ConnectionState.done)
              ? snapshot.data ?? const Iterable<String>.empty()
              : const Iterable<String>.empty();
          return Autocomplete<String>(
            optionsBuilder: (textEditingValue) => textEditingValue.text == ''
                ? const Iterable<String>.empty()
                : hints.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase())),
            onSelected: onHintSelected,
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) => TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: onFieldChanged,
              decoration: const InputDecoration(
                icon: Icon(Icons.info),
                border: OutlineInputBorder(),
                labelText: 'Event title',
              ),
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title for this event';
                }
                return null;
              },
            ),
            optionsViewBuilder: (context, onSelected, options) => Padding(
              padding: EdgeInsets.only(left: (IconTheme.of(context).size ?? 24.0) + 16.0, right: 56.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      height: min(options.length * 75.0, 200.0),
                      child: ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () => onSelected(option),
                            child: ListTile(
                              title: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}
