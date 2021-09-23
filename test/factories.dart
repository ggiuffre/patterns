import 'dart:math';

import 'package:patterns/src/data/event.dart';

final _randomGenerator = Random();

DateTime randomDate() => DateTime(
      _randomGenerator.nextInt(200) + 1850,
      _randomGenerator.nextInt(12 + 1),
      _randomGenerator.nextInt(31 + 1),
    );

String randomEventTitle() => ["a", "b", "c"][_randomGenerator.nextInt(3)];

Event randomEvent() => Event(randomEventTitle(), start: randomDate());
