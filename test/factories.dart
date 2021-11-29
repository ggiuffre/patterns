import 'dart:math';

import 'package:patterns/src/data/event.dart';

final _randomGenerator = Random();

DateTime randomDate({int sinceYear = 1850}) => DateTime(
      _randomGenerator.nextInt(DateTime.now().year - sinceYear) + sinceYear,
      _randomGenerator.nextInt(12 + 1),
      _randomGenerator.nextInt(31 + 1),
    );

String randomEventTitle() => ["a", "b", "c"][_randomGenerator.nextInt(3)];

double randomEventValue({double? max}) =>
    max == null ? _randomGenerator.nextDouble() : _randomGenerator.nextDouble() * max;

Event randomEvent({double? maxValue}) =>
    Event(randomEventTitle(), value: randomEventValue(max: maxValue), start: randomDate());
