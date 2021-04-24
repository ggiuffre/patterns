import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'event.dart';

final eventProvider =
    StateNotifierProvider<EventSequenceStateNotifier, List<Event>>((ref) => EventSequenceStateNotifier());

/// Sequence of all recorded events.
class EventSequenceStateNotifier extends StateNotifier<List<Event>> {
  EventSequenceStateNotifier() : super([]);

  /// Adds event to the sequence of events, placing it after all events with earlier time and
  /// before all events with later time.
  void addEvent(Event event) {
    // add the event at the end:
    state.add(event);

    // sort the list, assuming it is mostly sorted:
    for (int i = 0; i < state.length; i++) {
      Event key = state[i];
      int j = i - 1;
      while (j >= 0 && key < state[j]) {
        state[j + 1] = state[j];
        j--;
      }
      state[j + 1] = key;
    }
  }

  /// Removes event from the sequence.
  /// Returns true if event was in the sequence, false otherwise.
  bool removeEvent(Event event) => state.remove(event);
}
