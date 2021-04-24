import 'dart:math';

import 'package:patterns/data/correlations.dart';
import 'package:patterns/data/event.dart';
import 'package:test/test.dart';

void main() {
  final randomGenerator = Random();

  test("correlation is at least -1", () {
    final series1 = List.generate(
      100,
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    );
    final series2 = List.generate(
      30,
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    );
    final result = correlation(series1, series2);
    expect(result, greaterThanOrEqualTo(-1.0));
  });

  test("correlation is at most 1", () {
    final series1 = List.generate(
      100,
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    );
    final series2 = List.generate(
      30,
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    );
    final result = correlation(series1, series2);
    expect(result, lessThanOrEqualTo(1.0));
  });

  test("correlation of identical series is 1", () {
    final series = List.generate(
      30,
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    );
    final result = correlation(series, series);
    expect(result, equals(1.0));
  });

  test("correlation of non-overlapping series is -1", () {
    final series = List.generate(
      30,
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    ).toSet().toList();
    final result = correlation(series.sublist(0, series.length ~/ 2), series.sublist(series.length ~/ 2));
    expect(result, equals(-1.0));
  });

  test("correlation of series with different length can be calculated", () {
    final series1 = List.generate(
      randomGenerator.nextInt(50),
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    );
    final series2 = List.generate(
      randomGenerator.nextInt(50),
      (_) => Event(
        "title",
        DateTime(randomGenerator.nextInt(200) + 1850, randomGenerator.nextInt(12 + 1), randomGenerator.nextInt(28 + 1)),
      ),
    );
    final result = correlation(series1, series2);
    expect(result, isA<double>());
  });
}
