import 'package:patterns/src/data/event.dart';
import 'package:test/test.dart';

import 'factories.dart';

main() {
  group("The monthsLater extension method on DateTime", () {
    test("returns a date in the future compared to the original", () {
      final original = randomDate();
      final result = original.monthsLater(months: randomInt(max: 24));
      expect(original.isBefore(result), isTrue);
    });

    test("returns a date with the same day of the month, if the original day is below 29", () {
      final original = randomDate(day: randomInt(max: 28) + 1);
      final result = original.monthsLater(months: randomInt(max: 24));
      expect(original.day == result.day, isTrue);
    });

    test("returns April 30th, if increasing March 31st by 1 month", () {
      final original = randomDate(day: 31, month: 3);
      final result = original.monthsLater(months: 1);
      expect(result.day == 30, isTrue);
      expect(result.month == 4, isTrue);
    });

    test("returns a date in the next year, if increasing a date in December by 1 month", () {
      final original = randomDate(month: 12);
      final result = original.monthsLater(months: 1);
      expect(result.year == original.year + 1, isTrue);
    });
  });
}
