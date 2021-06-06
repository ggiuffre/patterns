import 'dart:math';

import 'package:patterns/data/event.dart';
import 'package:patterns/data/similarities.dart';
import 'package:test/test.dart';

import 'factories.dart';

void main() {
  final randomGenerator = Random();

  test("similarity is at least -1", () {
    final series1 = List.generate(100, (_) => Event("title", randomDate()));
    final series2 = List.generate(30, (_) => Event("title", randomDate()));
    final result = similarity(series1, series2);
    expect(result, greaterThanOrEqualTo(-1.0));
  });

  test("similarity is at most 1", () {
    final series1 = List.generate(100, (_) => Event("title", randomDate()));
    final series2 = List.generate(30, (_) => Event("title", randomDate()));
    final result = similarity(series1, series2);
    expect(result, lessThanOrEqualTo(1.0));
  });

  test("similarity of identical series is 1", () {
    final series = List.generate(30, (_) => Event("title", randomDate()));
    final result = similarity(series, series);
    expect(result, equals(1.0));
  });

  test("similarity of non-overlapping series is -1", () {
    final series = List.generate(30, (_) => Event("title", randomDate())).toSet().toList();
    final result = similarity(series.sublist(0, series.length ~/ 2), series.sublist(series.length ~/ 2));
    expect(result, equals(-1.0));
  });

  test("similarity of series with different length can be calculated", () {
    final series1 = List.generate(randomGenerator.nextInt(50), (_) => Event("title", randomDate()));
    final series2 = List.generate(randomGenerator.nextInt(50), (_) => Event("title", randomDate()));
    final result = similarity(series1, series2);
    expect(result, isA<double>());
  });

  test("similarity of identical series is greater than similarity of same pair with one unit displaced", () {
    final series1 = List.generate(30, (_) => Event("title", randomDate()));
    final series2 = [...series1.sublist(0, 29), Event("title", series1.last.time.add(const Duration(days: 1)))];
    expect(similarity(series1, series1), greaterThan(similarity(series1, series2)));
  });

  test("similarity is commutative in the two arguments that it takes", () {
    final series1 = List.generate(randomGenerator.nextInt(50), (_) => Event("title", randomDate()));
    final series2 = List.generate(randomGenerator.nextInt(50), (_) => Event("title", randomDate()));
    expect(similarity(series1, series2), equals(similarity(series2, series1)));
  });
}
