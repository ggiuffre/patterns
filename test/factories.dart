import 'dart:math';

import 'package:patterns/src/data/event.dart';

final _randomGenerator = Random();

String randomEventTitle() => String.fromCharCode(_randomGenerator.nextInt(26) + 97);

int randomInt({int max = 1000}) => _randomGenerator.nextInt(max);

double randomDouble({double max = 1}) => _randomGenerator.nextDouble() * max;

DateTime randomDate({int? day, int? month, int fromYear = 1990, int toYear = 2020}) => DateTime.utc(
      _randomGenerator.nextInt(toYear - fromYear) + fromYear,
      month ?? _randomGenerator.nextInt(12) + 1,
      day ?? _randomGenerator.nextInt(31) + 1,
    );

Event randomEvent({
  String? title,
  double? value,
  DateTime? start,
  double maxRandomValue = 1,
  int fromYear = 1990,
  int toYear = 2020,
}) =>
    Event(
      title ?? randomEventTitle(),
      value: value ?? randomDouble(max: maxRandomValue),
      start: start ?? randomDate(fromYear: fromYear, toYear: toYear),
    );

List<Event> randomEvents(
  int nEvents, {
  String? title,
  double? value,
  DateTime? start,
  double maxRandomValue = 1,
  int fromYear = 1990,
  int toYear = 2020,
}) =>
    Iterable.generate(
      nEvents,
      (_) => Event(
        title ?? randomEventTitle(),
        value: value ?? randomDouble(max: maxRandomValue),
        start: start ?? randomDate(fromYear: fromYear, toYear: toYear),
      ),
    ).toSet().toList();
