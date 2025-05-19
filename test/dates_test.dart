import 'package:divvy/models/chore.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // This group tests the getDatesFromWeek function
  group('week dates', () {
    test('Simple this week', () {
      // Test the function that returns a list of dates
      // in a week based on the weekday pattern.
      final startDate = DateTime(2025, 5, 6);
      // Tuesday, Friday, Sunday
      final daysOfWeek = [2, 5, 7];
      // Dummy end date
      final res = getDatesFromWeek(startDate, daysOfWeek, DateTime(2028, 1, 1));
      expect(res, [
        DateTime(2025, 5, 6),
        DateTime(2025, 5, 9),
        DateTime(2025, 5, 11),
      ]);
    });
    test('Single date', () {
      // Only want sundays
      final startDate = DateTime(2025, 5, 4);
      final daysOfWeek = [7];
      final res = getDatesFromWeek(startDate, daysOfWeek, DateTime(2028, 1, 1));
      expect(res, [DateTime(2025, 5, 4)]);
    });
    test('Every day this week', () {
      // Test the function that returns a list of dates
      // in a week based on the weekday pattern.
      final startDate = DateTime(2025, 5, 5);
      // Every day
      final daysOfWeek = [1, 2, 3, 4, 5, 6, 7];
      final res = getDatesFromWeek(startDate, daysOfWeek, DateTime(2028, 1, 1));
      expect(res, [
        DateTime(2025, 5, 5),
        DateTime(2025, 5, 6),
        DateTime(2025, 5, 7),
        DateTime(2025, 5, 8),
        DateTime(2025, 5, 9),
        DateTime(2025, 5, 10),
        DateTime(2025, 5, 11),
      ]);
    });
    test('Extra weekdays not counted', () {
      // Test the function that returns a list of dates
      // in a week based on the weekday pattern.
      final startDate = DateTime(2025, 5, 8);
      // Every day
      final daysOfWeek = [1, 2, 4, 7];
      final res = getDatesFromWeek(
        startDate,
        daysOfWeek,
        DateTime(2025, 5, 10),
      );
      expect(res, [DateTime(2025, 5, 8)]);
    });

    test('End of month OK', () {
      // Test the function that returns a list of dates
      // in a week based on the weekday pattern.
      final startDate = DateTime(2025, 4, 30);
      // Every day
      final daysOfWeek = [1, 3, 4, 7];
      final res = getDatesFromWeek(startDate, daysOfWeek, DateTime(2028, 1, 1));
      expect(res, [
        DateTime(2025, 4, 30),
        DateTime(2025, 5, 1),
        DateTime(2025, 5, 4),
      ]);
    });
  });

  group('Day list', () {
    test('Weekly recurrence month edge w/ spring savings', () {
      final startDate = DateTime(2025, 2, 22);
      // Every saturday
      final dates = getDateList(
        ChoreFrequency(
          pattern: Frequency.weekly,
          daysOfWeek: [6],
          startDate: startDate,
        ),
      );

      expect(dates.take(13).toList(), [
        DateTime(2025, 2, 22),
        DateTime(2025, 3, 1),
        DateTime(2025, 3, 8),
        DateTime(2025, 3, 15),
        DateTime(2025, 3, 22),
        DateTime(2025, 3, 29),
        DateTime(2025, 4, 5),
        DateTime(2025, 4, 12),
        DateTime(2025, 4, 19),
        DateTime(2025, 4, 26),
        DateTime(2025, 5, 3),
        DateTime(2025, 5, 10),
        DateTime(2025, 5, 17),
      ]);
    });
    test('Weekly recurrence with multiple days of week', () {
      final startDate = DateTime(2025, 2, 22);
      // Every saturday & monday
      final dates = getDateList(
        ChoreFrequency(
          pattern: Frequency.weekly,
          daysOfWeek: [1, 6],
          startDate: startDate,
        ),
      );

      expect(dates.take(26).toList(), [
        DateTime(2025, 2, 22),
        DateTime(2025, 2, 24),
        DateTime(2025, 3, 1),
        DateTime(2025, 3, 3),
        DateTime(2025, 3, 8),
        DateTime(2025, 3, 10),
        DateTime(2025, 3, 15),
        DateTime(2025, 3, 17),
        DateTime(2025, 3, 22),
        DateTime(2025, 3, 24),
        DateTime(2025, 3, 29),
        DateTime(2025, 3, 31),
        DateTime(2025, 4, 5),
        DateTime(2025, 4, 7),
        DateTime(2025, 4, 12),
        DateTime(2025, 4, 14),
        DateTime(2025, 4, 19),
        DateTime(2025, 4, 21),
        DateTime(2025, 4, 26),
        DateTime(2025, 4, 28),
        DateTime(2025, 5, 3),
        DateTime(2025, 5, 5),
        DateTime(2025, 5, 10),
        DateTime(2025, 5, 12),
        DateTime(2025, 5, 17),
        DateTime(2025, 5, 19),
      ]);
    });

    test('Daily recurrence daylight savings fall edge', () {
      final startDate = DateTime(2024, 11, 3);
      final dates = getDateList(
        ChoreFrequency(
          pattern: Frequency.daily,
          daysOfWeek: [],
          startDate: startDate,
        ),
      );
      expect(dates.length, 366);
      // Expect "biggest" day to be start + 90 days
      expect(
        dates.reduce((a, b) => a.isAfter(b) ? a : b),
        startDate.add(const Duration(days: 365)),
      );
      // Expect "smallest" day to be start date
      expect(dates.reduce((a, b) => a.isBefore(b) ? a : b), startDate);
      // Expect no duplicate dates
      expect(dates.toSet().length, dates.length);
    });
    test('Monthly recurring dates', () {
      final startDate = DateTime(2025, 1, 1);
      final dates = getDateList(
        ChoreFrequency(
          pattern: Frequency.monthly,
          daysOfWeek: [],
          startDate: startDate,
        ),
      );
      expect(dates, [
        DateTime(2025, 1, 1),
        DateTime(2025, 2, 1),
        DateTime(2025, 3, 1),
        DateTime(2025, 4, 1),
        DateTime(2025, 5, 1),
        DateTime(2025, 6, 1),
        DateTime(2025, 7, 1),
        DateTime(2025, 8, 1),
        DateTime(2025, 9, 1),
        DateTime(2025, 10, 1),
        DateTime(2025, 11, 1),
        DateTime(2025, 12, 1),
      ]);
    });
    test('Monthly recurring dates, different number of days', () {
      final startDate = DateTime(2025, 4, 10);
      final dates = getDateList(
        ChoreFrequency(
          pattern: Frequency.monthly,
          daysOfWeek: [],
          startDate: startDate,
        ),
      );
      expect(dates, [
        DateTime(2025, 4, 10),
        DateTime(2025, 5, 10),
        DateTime(2025, 6, 10),
        DateTime(2025, 7, 10),
        DateTime(2025, 8, 10),
        DateTime(2025, 9, 10),
        DateTime(2025, 10, 10),
        DateTime(2025, 11, 10),
        DateTime(2025, 12, 10),
        DateTime(2026, 1, 10),
        DateTime(2026, 2, 10),
        DateTime(2026, 3, 10),
      ]);
    });
  });
}
