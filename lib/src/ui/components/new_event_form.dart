import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/date_formatting.dart';
import '../../data/event.dart';
import '../../data/food_info.dart';
import '../../data/mood.dart';
import '../../data/repositories/events.dart';
import '../../data/social_event.dart';
import 'constrained_card.dart';
import 'error_card.dart';

class NewEventForm extends ConsumerStatefulWidget {
  final void Function() onSubmit;

  const NewEventForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _NewEventFormState createState() => _NewEventFormState();
}

class _NewEventFormState extends ConsumerState<NewEventForm> {
  final _formKey = GlobalKey<FormState>();

  EventType _eventType = EventType.customEvent;
  String _eventTitle = "";
  double _eventValue = 1;
  FoodInfo _foodInfo = foodInfo.values.first;
  Mood _mood = const Mood();
  SocialEvent _socialEventInfo = const SocialEvent(type: "");
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
                      child: Text("Event type", style: Theme.of(context).textTheme.headline5),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _EventTypeSelector(
                        groupValue: _eventType,
                        onChipSelected: (value) => setState(() => _eventType = value),
                        values: EventType.values,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_eventType != EventType.customEvent &&
                _eventType != EventType.meal &&
                _eventType != EventType.moodMeasurement &&
                _eventType != EventType.socialEvent)
              const ConstrainedCard(child: ErrorCard(text: "Not implemented yet. Work in progress...")),
            if (_eventType == EventType.customEvent)
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
              )
            else if (_eventType == EventType.meal)
              ConstrainedCard(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Food properties", style: Theme.of(context).textTheme.headline5),
                      ),
                      _FoodRadioInput(
                        values: FoodType.values,
                        onChipSelected: (food) => setState(() => _foodInfo = food),
                        autoValidate: _autoValidate,
                      ),
                    ],
                  ),
                ),
              )
            else if (_eventType == EventType.moodMeasurement)
              ConstrainedCard(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Your mood", style: Theme.of(context).textTheme.headline5),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(flex: 100, child: Text("Happiness:")),
                            Flexible(
                              flex: 162,
                              child: Slider.adaptive(
                                value: _mood.happiness,
                                min: -1,
                                max: 1,
                                onChanged: (newValue) => setState(() => _mood = _mood.copyWith(happiness: newValue)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(flex: 100, child: Text("Stress:")),
                            Flexible(
                              flex: 162,
                              child: Slider.adaptive(
                                value: _mood.stress,
                                min: -1,
                                max: 1,
                                onChanged: (newValue) => setState(() => _mood = _mood.copyWith(stress: newValue)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(flex: 100, child: Text("Energy:")),
                            Flexible(
                              flex: 162,
                              child: Slider.adaptive(
                                value: _mood.energy,
                                min: -1,
                                max: 1,
                                onChanged: (newValue) => setState(() => _mood = _mood.copyWith(energy: newValue)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_eventType == EventType.socialEvent)
              ConstrainedCard(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Social event", style: Theme.of(context).textTheme.headline5),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          children:
                              {"dinner", "party", "lunch", "brunch", "cinema", "aperitif", "date", "visit", "other"}
                                  .map(
                                    (eventType) => ChoiceChip(
                                      label: Text(eventType),
                                      selected: eventType == _socialEventInfo.type,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _socialEventInfo = _socialEventInfo.copyWith(type: eventType));
                                        }
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      if (_socialEventInfo.type == "other")
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.info),
                              labelText: 'Type of social event',
                            ),
                            autovalidateMode:
                                _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please give a label to this event';
                              }
                              return null;
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.people),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Number of people (including you)"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  key: Key("numberOfPeople${_socialEventInfo.numberOfPeople}"),
                                  initialValue: _socialEventInfo.numberOfPeople?.toString() ?? "",
                                  onChanged: (value) {
                                    final intValue = int.tryParse(value);
                                    if (intValue != null) {
                                      setState(
                                          () => _socialEventInfo = _socialEventInfo.copyWith(numberOfPeople: intValue));
                                    }
                                  },
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    prefixIcon: IconButton(
                                      onPressed: () {
                                        final currentValue = _socialEventInfo.numberOfPeople;
                                        if (currentValue != null) {
                                          if (currentValue > 2) {
                                            setState(() => _socialEventInfo =
                                                _socialEventInfo.copyWith(numberOfPeople: currentValue - 1));
                                          } else {
                                            // reset number of people to null (copyWith can't do it):
                                            setState(() => _socialEventInfo = SocialEvent(type: _socialEventInfo.type));
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.remove),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() => _socialEventInfo = _socialEventInfo.copyWith(
                                            numberOfPeople: (_socialEventInfo.numberOfPeople ?? 1) + 1));
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(),
                                  validator: (value) {
                                    final intValue = int.tryParse(value ?? "");
                                    if (intValue != null && intValue < 2) {
                                      return 'This must be at least 2';
                                    }
                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
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
            if (_eventType == EventType.customEvent)
              ConstrainedCard(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Event value", style: Theme.of(context).textTheme.headline5),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: _eventValue.toString(),
                          onChanged: (value) => setState(() => _eventValue = double.tryParse(value) ?? _eventValue),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.tune),
                            labelText: 'Numeric value',
                          ),
                          autovalidateMode:
                              _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a value for this event';
                            } else if (double.tryParse(value ?? "") == null) {
                              return 'Please enter a valid numeric value for this event';
                            }
                            return null;
                          },
                        ),
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
        if (_eventType == EventType.meal) {
          final nutrientEvents = _eventsFromFoodInfo(_foodInfo, time: _eventStartTime);
          if (_eventFrequency != Frequency.once) {
            final events = nutrientEvents
                .map(
                  (nutrientEvent) => recurringEvents(
                    title: nutrientEvent.title,
                    value: nutrientEvent.value,
                    range: DateTimeRange(start: _eventStartTime, end: _eventEndTime),
                    frequency: _eventFrequency,
                    interval: _eventInterval,
                  ),
                )
                .expand((e) => e)
                .toList();
            for (final event in events) {
              ref.read(eventProvider).add(event);
            }
          } else {
            for (final nutrientEvent in nutrientEvents) {
              await ref.read(eventProvider).add(nutrientEvent);
            }
          }
        } else if (_eventType == EventType.moodMeasurement) {
          final moodEvents = _eventsFromMoodParams(_mood, time: _eventStartTime);
          if (_eventFrequency != Frequency.once) {
            final events = moodEvents
                .map(
                  (nutrientEvent) => recurringEvents(
                    title: nutrientEvent.title,
                    value: nutrientEvent.value,
                    range: DateTimeRange(start: _eventStartTime, end: _eventEndTime),
                    frequency: _eventFrequency,
                    interval: _eventInterval,
                  ),
                )
                .expand((e) => e)
                .toList();
            for (final event in events) {
              ref.read(eventProvider).add(event);
            }
          } else {
            for (final nutrientEvent in moodEvents) {
              await ref.read(eventProvider).add(nutrientEvent);
            }
          }
        } else if (_eventType == EventType.customEvent) {
          if (_eventFrequency != Frequency.once) {
            final events = recurringEvents(
              title: _eventTitle,
              value: _eventValue,
              range: DateTimeRange(start: _eventStartTime, end: _eventEndTime),
              frequency: _eventFrequency,
              interval: _eventInterval,
            );
            for (final event in events) {
              ref.read(eventProvider).add(event);
            }
          } else {
            await ref.read(eventProvider).add(Event(_eventTitle, value: _eventValue, start: _eventStartTime));
          }
        }
        widget.onSubmit();
      }
    }
  }

  Set<Event> _eventsFromFoodInfo(FoodInfo food, {required DateTime time}) => {
        Event("calories intake", value: food.calories, start: time),
        if (food.fat != null && food.fat != 0) Event("fat intake", value: food.fat!, start: time),
        if (food.carbs != null && food.carbs != 0) Event("carbs intake", value: food.carbs!, start: time),
        if (food.fiber != null && food.fiber != 0) Event("fiber intake", value: food.fiber!, start: time),
        if (food.protein != null && food.protein != 0) Event("protein intake", value: food.protein!, start: time),
        if (food.iron != null && food.iron != 0) Event("iron intake", value: food.iron!, start: time),
      };

  Set<Event> _eventsFromMoodParams(Mood mood, {required DateTime time}) => {
        if (mood.happiness != 0) Event("happiness", value: mood.happiness, start: time),
        if (mood.stress != 0) Event("stress", value: mood.stress, start: time),
        if (mood.energy != 0) Event("perceived energy", value: mood.energy, start: time),
      };
}

/// Type of new [Event] that a user can create, for example social event,
/// sports event, food consumption, perceived mood...
enum EventType {
  customEvent,
  sportsEvent,
  meal,
  socialEvent,
  musicListening,
  moodMeasurement,
}

class _EventTypeSelector extends StatefulWidget {
  final EventType groupValue;
  final Iterable<EventType> values;
  final void Function(EventType) onChipSelected;

  const _EventTypeSelector({
    Key? key,
    required this.groupValue,
    required this.values,
    required this.onChipSelected,
  }) : super(key: key);

  @override
  State<_EventTypeSelector> createState() => _EventTypeSelectorState();
}

class _EventTypeSelectorState extends State<_EventTypeSelector> {
  bool minimized = true;

  static const eventTypeLabels = {
    EventType.customEvent: "custom event",
    EventType.sportsEvent: "workout/training",
    EventType.meal: "meal",
    EventType.socialEvent: "social event",
    EventType.musicListening: "listening to music",
    EventType.moodMeasurement: "write down your mood",
  };

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 750),
        curve: Curves.fastOutSlowIn,
        constraints: minimized ? const BoxConstraints(maxHeight: 50) : const BoxConstraints(maxHeight: 600),
        child: ListView(
          shrinkWrap: true,
          children: [
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: widget.values
                  .where((eventType) => eventTypeLabels.containsKey(eventType))
                  .map(
                    (eventType) => ChoiceChip(
                      label: Text(eventTypeLabels[eventType] ?? ""),
                      selected: eventType == widget.groupValue,
                      onSelected: (selected) {
                        setState(() => minimized = false);
                        if (selected) {
                          widget.onChipSelected(eventType);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
            if (!minimized)
              TextButton.icon(
                icon: const Icon(Icons.arrow_drop_up),
                onPressed: () => setState(() => minimized = true),
                label: const Text("Collapse"),
              ),
          ],
        ),
      );
}

class _EventTitleTextField extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<Set<String>>(
        future: ref.read(eventProvider).list.last.then((events) => events.map((e) => e.title).toSet()),
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
                        padding: const EdgeInsets.all(8.0),
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

class _FoodRadioInput extends StatefulWidget {
  final Iterable<FoodType> values;
  final void Function(FoodInfo) onChipSelected;
  final bool autoValidate;

  const _FoodRadioInput({
    Key? key,
    required this.values,
    required this.onChipSelected,
    this.autoValidate = false,
  }) : super(key: key);

  @override
  State<_FoodRadioInput> createState() => _FoodRadioInputState();
}

class _FoodRadioInputState extends State<_FoodRadioInput> {
  FoodInfo _groupValue = foodInfo.values.first;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: widget.values
                    .where((food) => foodInfo.containsKey(food))
                    .map((food) => foodInfo[food])
                    .map(
                      (food) => ChoiceChip(
                        label: Text(food?.label ?? ""),
                        selected: food == _groupValue,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _groupValue = food!);
                            widget.onChipSelected(food!);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.tune),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Text("${_groupValue.calories} calories"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _NutrientTextField(
                    key: Key("${_groupValue.label}_calories"),
                    nutrientName: "calories",
                    measurementUnit: "kcal",
                    initialValue: _groupValue.calories,
                    onChanged: (newValue) {
                      final newFoodValue = _groupValue.copyWith(calories: newValue);
                      setState(() => _groupValue = newFoodValue);
                      widget.onChipSelected(newFoodValue);
                    },
                    autovalidateMode:
                        widget.autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _NutrientTextField(
                    key: Key("${_groupValue.label}_fat"),
                    nutrientName: "fat",
                    initialValue: _groupValue.fat,
                    onChanged: (newValue) {
                      final newFoodValue = _groupValue.copyWith(fat: newValue);
                      setState(() => _groupValue = newFoodValue);
                      widget.onChipSelected(newFoodValue);
                    },
                    autovalidateMode:
                        widget.autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _NutrientTextField(
                    key: Key("${_groupValue.label}_carbs"),
                    nutrientName: "carbs",
                    initialValue: _groupValue.carbs,
                    onChanged: (newValue) {
                      final newFoodValue = _groupValue.copyWith(carbs: newValue);
                      setState(() => _groupValue = newFoodValue);
                      widget.onChipSelected(newFoodValue);
                    },
                    autovalidateMode:
                        widget.autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _NutrientTextField(
                    key: Key("${_groupValue.label}_fiber"),
                    nutrientName: "fiber",
                    initialValue: _groupValue.fiber,
                    onChanged: (newValue) {
                      final newFoodValue = _groupValue.copyWith(fiber: newValue);
                      setState(() => _groupValue = newFoodValue);
                      widget.onChipSelected(newFoodValue);
                    },
                    autovalidateMode:
                        widget.autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _NutrientTextField(
                    key: Key("${_groupValue.label}_protein"),
                    nutrientName: "protein",
                    initialValue: _groupValue.protein,
                    onChanged: (newValue) {
                      final newFoodValue = _groupValue.copyWith(protein: newValue);
                      setState(() => _groupValue = newFoodValue);
                      widget.onChipSelected(newFoodValue);
                    },
                    autovalidateMode:
                        widget.autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _NutrientTextField(
                    key: Key("${_groupValue.label}_iron"),
                    nutrientName: "iron",
                    measurementUnit: "mg",
                    initialValue: _groupValue.iron,
                    onChanged: (newValue) {
                      final newFoodValue = _groupValue.copyWith(iron: newValue);
                      setState(() => _groupValue = newFoodValue);
                      widget.onChipSelected(newFoodValue);
                    },
                    autovalidateMode:
                        widget.autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _NutrientTextField extends StatelessWidget {
  final String nutrientName;
  final void Function(double?) onChanged;
  final double? initialValue;
  final AutovalidateMode? autovalidateMode;
  final String? measurementUnit;

  const _NutrientTextField(
      {Key? key,
      required this.nutrientName,
      required this.onChanged,
      this.initialValue,
      this.autovalidateMode,
      this.measurementUnit = "g"})
      : super(key: key);

  @override
  Widget build(BuildContext context) => TextFormField(
        keyboardType: TextInputType.number,
        initialValue: initialValue == null ? "" : initialValue.toString(),
        onChanged: (newStringValue) {
          final newValue = double.tryParse(newStringValue);
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.local_fire_department),
          labelText: "${nutrientName[0].toUpperCase()}${nutrientName.substring(1)}",
          suffixText: "$measurementUnit / 100g",
        ),
        autovalidateMode: autovalidateMode,
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter the amount of $nutrientName that this food contains';
          } else if (double.tryParse(value ?? "") == null) {
            return 'Please enter a valid number';
          }
          return null;
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
                  const Padding(
                    padding: EdgeInsets.all(8.0),
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
                              constraints: const BoxConstraints(minWidth: 48.0),
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
