import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';

class NewEventPage extends StatefulWidget {
  final void Function() onSubmit;

  const NewEventPage({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _NewEventPageState createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
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

  @override
  void initState() {
    _dateFieldController.text = _eventTime.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("New event"),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("What?"),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("When?"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // context.read(eventProvider.notifier).addEvent(Event(_eventTitle, _eventTime));
                      context.read(eventProvider).add(Event(_eventTitle, _eventTime));
                      // if (user?.uid != null) {
                      //   await FirebaseFirestore.instance
                      //       .collection("users")
                      //       .doc(user!.uid)
                      //       .collection("events")
                      //       .add({"title": _eventTitle, "time": _eventTime});
                      // }
                      widget.onSubmit();
                    }
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
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
