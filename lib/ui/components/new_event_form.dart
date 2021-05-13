import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';

class NewEventForm extends StatefulWidget {
  final void Function() onSubmit;

  const NewEventForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _NewEventFormState createState() => _NewEventFormState();
}

class _NewEventFormState extends State<NewEventForm> {
  static const _textFieldHints = [
    'breakfast with cereals',
    'breakfast with bread+butter',
    'dinner with carbs',
    'dinner without carbs',
    'nuts before sleeping',
    'good sleep',
    'bad sleep',
  ]; // TODO suggest titles previously entered by user

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
  late TextEditingController _textFieldController;

  String _eventTitle = "";
  DateTime _eventTime = DateTime.now();
  Frequency _eventFrequency = Frequency.once; // frequency with which the event being created occurs
  bool _addingEvent = false; // whether an event is in the process of being added

  @override
  void initState() {
    _dateFieldController.text = _eventTime.toString();
    super.initState();
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
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Event title", style: Theme.of(context).textTheme.headline5),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RawAutocomplete<String>(
                        optionsBuilder: (textEditingValue) => textEditingValue.text == ''
                            ? const Iterable<String>.empty()
                            : _textFieldHints
                                .where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase())),
                        onSelected: (selection) => setState(() => _eventTitle = selection),
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          _textFieldController = textEditingController;
                          return TextFormField(
                            controller: _textFieldController,
                            focusNode: focusNode,
                            onChanged: (newTitle) => setState(() => _eventTitle = newTitle),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.info),
                              border: OutlineInputBorder(),
                              labelText: 'Event title',
                            ),
                            textInputAction: TextInputAction.next,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) => Padding(
                          padding: EdgeInsets.only(left: (IconTheme.of(context).size ?? 24.0) + 16.0, right: 32.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: SizedBox(
                                height: 200.0,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(8.0),
                                  itemCount: options.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index >= options.length) {
                                      return TextButton(
                                        child: const Text('clear'),
                                        onPressed: () => _textFieldController.clear(),
                                      );
                                    }
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
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: _addingEvent
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ElevatedButton(
                      onPressed: _submitEvent,
                      child: const Text("Submit"),
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
      print("adding...");
      setState(() => _addingEvent = true);
      if (_eventFrequency != Frequency.once) {
        final events = eventsAtInterval(
          title: _eventTitle,
          range: DateTimeRange(start: _eventTime, end: _eventTime.add(const Duration(days: 90))),
          frequency: _eventFrequency,
        );
        for (final event in events) {
          print(event);
          context.read(eventProvider).add(event);
        }
      } else {
        await context.read(eventProvider).add(Event(_eventTitle, _eventTime));
      }
      widget.onSubmit();
    }
  }
}
