import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patterns/data/date_formatting.dart';

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
  final _formKey = GlobalKey<FormState>();

  String _eventTitle = "";
  DateTime _eventStartTime = DateTime.now();
  DateTime _eventEndTime = DateTime.now();
  Frequency _eventFrequency = Frequency.once; // frequency at which the new event should occur
  int _eventInterval = 1; // days/weeks/months/... (depending on the frequency) between each instance of the new event
  bool _addingEvent = false; // whether the new event is in the process of being added
  bool _autoValidate = false;

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
                        autoValidate: _autoValidate,
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
                    _EventDateRangeInput(
                      initialValue: DateTimeRange(start: _eventStartTime, end: _eventEndTime),
                      onChange: (newRange) => setState(() {
                        _eventStartTime = newRange.start;
                        _eventEndTime = newRange.end;
                      }),
                    ),
                    _EventFrequencyExpansionTile(
                      eventFrequency: _eventFrequency,
                      eventInterval: _eventInterval,
                      onChangeFrequency: (newFrequency) => setState(() {
                        // update the frequency to the new value:
                        _eventFrequency = newFrequency ?? _eventFrequency;

                        // reset the event interval, as it depends on the frequency:
                        _eventInterval = 1;

                        // make sure the event ending date has a sensible value for one-time events:
                        if (newFrequency == Frequency.once) {
                          _eventEndTime = _eventStartTime;
                        }
                      }),
                      onIncreaseInterval: () => setState(() => _eventInterval++),
                      onDecreaseInterval: () => setState(() => _eventInterval = max(1, _eventInterval - 1)),
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

  Future<void> _submitEvent() async {
    final formState = _formKey.currentState;
    if (formState != null) {
      setState(() => _autoValidate = true);
      if (formState.validate()) {
        setState(() => _addingEvent = true);
        if (_eventFrequency != Frequency.once) {
          final events = recurringEvents(
            title: _eventTitle,
            range: DateTimeRange(start: _eventStartTime, end: _eventEndTime),
            frequency: _eventFrequency,
            interval: _eventInterval,
          );
          for (final event in events) {
            context.read(eventProvider).add(event);
          }
        } else {
          await context.read(eventProvider).add(Event(_eventTitle, start: _eventStartTime));
        }
        widget.onSubmit();
      }
    }
  }
}

class _EventTitleTextField extends StatelessWidget {
  final void Function(String) onHintSelected;
  final void Function(String) onFieldChanged;
  final bool autoValidate;

  const _EventTitleTextField({
    Key? key,
    required this.onHintSelected,
    required this.onFieldChanged,
    this.autoValidate = false,
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
              autovalidateMode: autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
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

class _EventDateRangeInput extends StatelessWidget {
  final DateTimeRange initialValue;
  final void Function(DateTimeRange) onChange;

  const _EventDateRangeInput({Key? key, required this.initialValue, required this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                final newStartTime = await _selectDate(context, initialDate: initialValue.start);
                final compatibleEndTime = newStartTime.isAfter(initialValue.end) ? newStartTime : initialValue.end;
                onChange(DateTimeRange(start: newStartTime, end: compatibleEndTime));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("Start")),
                  Text(formattedDate(initialValue.start)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                final newEndTime = await _selectDate(context, initialDate: initialValue.end);
                final compatibleStartTime = newEndTime.isBefore(initialValue.start) ? newEndTime : initialValue.start;
                onChange(DateTimeRange(start: compatibleStartTime, end: newEndTime));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("End")),
                  Text(formattedDate(initialValue.end)),
                ],
              ),
            ),
          ),
        ],
      );

  Future<DateTime> _selectDate(BuildContext context, {required DateTime initialDate}) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    return (newDate != initialDate ? newDate : initialDate) ?? initialDate;
  }
}

class _EventFrequencyExpansionTile extends StatelessWidget {
  final Frequency eventFrequency;
  final int eventInterval;
  final void Function(Frequency?)? onChangeFrequency;
  final void Function()? onIncreaseInterval;
  final void Function()? onDecreaseInterval;

  static const _frequencies = {
    Frequency.once: "Does not repeat",
    Frequency.daily: "Occurs daily",
    Frequency.weekly: "Occurs weekly",
    Frequency.monthly: "Occurs monthly",
    Frequency.yearly: "Occurs yearly",
  };

  const _EventFrequencyExpansionTile({
    Key? key,
    this.eventFrequency = Frequency.once,
    this.eventInterval = 1,
    this.onChangeFrequency,
    this.onIncreaseInterval,
    this.onDecreaseInterval,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ExpansionTile(
        leading: const Icon(Icons.repeat),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          _recurringEventStringDescription(frequency: eventFrequency, interval: eventInterval),
        ),
        children: [
          for (final frequency in Frequency.values)
            RadioListTile<Frequency>(
              title: Text(_frequencies[frequency]!),
              value: frequency,
              groupValue: eventFrequency,
              onChanged: onChangeFrequency,
              dense: true,
            ),
          if (eventFrequency != Frequency.once)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Occurs every:"),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: onDecreaseInterval,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              constraints: BoxConstraints(minWidth: 48.0),
                              alignment: Alignment.center,
                              child: Text(
                                _intervalLabel(frequency: eventFrequency, interval: eventInterval),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: onIncreaseInterval,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

  String _intervalLabel({required Frequency frequency, required int interval}) {
    const intervalTypes = {
      Frequency.daily: "day",
      Frequency.weekly: "week",
      Frequency.monthly: "month",
      Frequency.yearly: "year",
    };

    final intervalType = intervalTypes[frequency];
    if (intervalType != null) {
      return "$interval $intervalType${interval > 1 ? "s" : ""}";
    } else {
      return interval.toString();
    }
  }

  String _recurringEventStringDescription({required Frequency frequency, required int interval}) {
    if (frequency == Frequency.once) {
      return "Does not repeat";
    } else if (frequency == Frequency.daily) {
      if (interval < 2) {
        return "Occurs daily";
      } else if (interval == 2) {
        return "Occurs every other day";
      } else {
        return "Occurs every $interval days";
      }
    } else if (frequency == Frequency.weekly) {
      if (interval < 2) {
        return "Occurs weekly";
      } else if (interval == 2) {
        return "Occurs every other week";
      } else {
        return "Occurs every $interval weeks";
      }
    } else if (frequency == Frequency.monthly) {
      if (interval < 2) {
        return "Occurs monthly";
      } else if (interval == 2) {
        return "Occurs every other month";
      } else {
        return "Occurs every $interval months";
      }
    } else if (frequency == Frequency.yearly) {
      if (interval < 2) {
        return "Occurs yearly";
      } else if (interval == 2) {
        return "Occurs every other year";
      } else {
        return "Occurs every $interval years";
      }
    } else {
      return "Does not repeat";
    }
  }
}
