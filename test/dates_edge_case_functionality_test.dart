import 'package:flutter_test/flutter_test.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/models/chore.dart';

void main() {
  group('getDateList - Daily', () {
    test('Daily recurrence from March 1, 2025', () {
      final start = DateTime(2025, 3, 1);
      final dates = getDateList(
        ChoreFrequency(pattern: Frequency.daily, daysOfWeek: []),
        start,
      );
      expect(dates.length, 92);
      expect(dates.first, start);
      expect(dates.last, start.add(const Duration(days: 90)));
    });

    test('Daily recurrence handles DST spring forward', () {
      final start = DateTime(2025, 3, 9); // Day before US DST change
      final dates = getDateList(
        ChoreFrequency(pattern: Frequency.daily, daysOfWeek: []),
        start,
      );
      expect(dates.length, 92);
    });
  });

  group('getDateList - Weekly', () {
    test('Weekly recurrence on Tue and Sat from April 1, 2025', () {
      final start = DateTime(2025, 4, 1); // Tuesday
      final days = [2, 6];
      final dates = getDateList(
        ChoreFrequency(pattern: Frequency.weekly, daysOfWeek: days),
        start,
      );
      expect(
        dates.any((d) => d.weekday == 3),
        false,
      ); // Should not include Wednesday
      expect(dates.every((d) => days.contains(d.weekday)), true);
    });

    test('Weekly recurrence skips invalid weekdays', () {
      final start = DateTime(2025, 4, 1);
      final dates = getDateList(
        ChoreFrequency(pattern: Frequency.weekly, daysOfWeek: []),
        start,
      );
      expect(dates.length, 0); // No days specified
    });
  });

  group('getDateList - Monthly', () {
    // test('Monthly recurrence starting on last day of Feb in leap year', () {
    //   final start = DateTime(2024, 2, 29);
    //   final dates = getDateList(
    //     ChoreFrequency(pattern: Frequency.monthly, daysOfWeek: []),
    //     start,
    //   );
    //   expect(dates.first, start);
    //   expect(dates[1], DateTime(2024, 3, 31)); // Should handle "last day" logic
    // });

    test('Monthly recurrence starts mid-month', () {
      final start = DateTime(2025, 6, 15);
      final dates = getDateList(
        ChoreFrequency(pattern: Frequency.monthly, daysOfWeek: []),
        start,
      );
      expect(dates, [
        DateTime(2025, 6, 15),
        DateTime(2025, 7, 15),
        DateTime(2025, 8, 15),
      ]);
    });
  });

  group('Utility Functions', () {
    test('compareDate ignores time', () {
      final a = DateTime(2025, 5, 5, 23, 59);
      final b = DateTime(2025, 5, 5, 0, 1);
      expect(compareDate(a, b), true);
    });

    test('isLastDay detects end-of-month', () {
      expect(isLastDay(DateTime(2025, 4, 30)), true);
      expect(isLastDay(DateTime(2025, 4, 29)), false);
    });

    test('adjustDaylightSavings keeps dates stable', () {
      final a = DateTime(2025, 11, 2, 23);
      final b = adjustDaylightSavings(a);
      expect(b.hour, 0); // Adjusted forward 1 hour
    });
  });
}
