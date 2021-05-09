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

const weekDays = {
  DateTime.monday: "Monday",
  DateTime.tuesday: "Tuesday",
  DateTime.wednesday: "Wednesday",
  DateTime.thursday: "Thursday",
  DateTime.friday: "Friday",
  DateTime.saturday: "Saturday",
  DateTime.sunday: "Sunday",
};

class _NewEventFormState extends State<NewEventForm> {
  static const List<String> _textFieldHints = <String>[
    'breakfast with cereals',
    'breakfast with bread+butter',
    'dinner with carbs',
    'dinner without carbs',
    'nuts before sleeping',
    'good sleep',
    'bad sleep',
  ];

  final _formKey = GlobalKey<FormState>();
  final _dateFieldController = TextEditingController();
  late TextEditingController _textFieldController;

  String _eventTitle = "";
  DateTime _eventTime = DateTime.now();
  bool _recurringEvent = false; // whether the event being creates recurs at a precise time interval
  int _recurringEventTime = DateTime.monday; // when the event being created occurs, if it is a recurring one
  bool _addingEvent = false; // whether an event is in the process of being added

  @override
  void initState() {
    _dateFieldController.text = _eventTime.toString();
    super.initState();
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
                      child: Row(
                        children: [
                          const Text("Recurring event?"),
                          Switch(value: _recurringEvent, onChanged: (v) => setState(() => _recurringEvent = v)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _recurringEvent
                          ? Column(
                              children: [
                                for (final weekDay in weekDays.keys)
                                  RadioListTile<int>(
                                    title: Text("Every ${weekDays[weekDay]}"),
                                    value: weekDay,
                                    groupValue: _recurringEventTime,
                                    onChanged: (v) => setState(() => _recurringEventTime = v ?? _recurringEventTime),
                                  ),
                              ],
                            )
                          : TextFormField(
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: _addingEvent
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _addingEvent = true);
                          if (_recurringEvent) {
                            final currentWeekDay = DateTime.now().weekday;
                            final offset = _recurringEventTime - currentWeekDay % 7;
                            final recurringEventClosestDate = DateTime.now().add(Duration(days: offset));
                            List.generate(5, (index) => recurringEventClosestDate.add(Duration(days: (index - 3) * 7)))
                                .map((t) => Event(_eventTitle, t))
                                .forEach((event) async => await context.read(eventProvider).add(event));
                          } else {
                            await context.read(eventProvider).add(Event(_eventTitle, _eventTime));
                          }
                          widget.onSubmit();
                        }
                      },
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
}
