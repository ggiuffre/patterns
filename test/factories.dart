import 'dart:math';

import 'package:patterns/data/event.dart';

final _randomGenerator = Random();
final randomDate = () => DateTime(
      _randomGenerator.nextInt(200) + 1850,
      _randomGenerator.nextInt(12 + 1),
      _randomGenerator.nextInt(31 + 1),
    );
final randomEventTitle = () => ["a", "b", "c"][_randomGenerator.nextInt(3)];
final randomEvent = () => Event(randomEventTitle(), start: randomDate());
