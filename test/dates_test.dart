// import 'package:divvy/models/chore.dart';
// import 'package:divvy/util/date_funcs.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {

//   group('week dates', () {});
//   group('recurrenceDates', () {
//     group('daily', () {
//       test('Daily recurrence normal', () {
//         final startDate = DateTime(2024, 11, 12);
//         final endDate = DateTime(2024, 11, 16);
//         final dates = getDateList(Frequency.daily, startDate);

//         expect(dates, [
//           DateTime(2024, 11, 12),
//           DateTime(2024, 11, 13),
//           DateTime(2024, 11, 14),
//           DateTime(2024, 11, 15),
//           DateTime(2024, 11, 16),
//         ]);
//       });
//       test('Daily recurrence daylight savings fall', () {
//         final startDate = DateTime(2024, 11, 1);
//         final endDate = DateTime(2024, 11, 5);
//         final dates = recurrenceDates(startDate, endDate, Frequency.daily);

//         expect(dates, [
//           DateTime(2024, 11, 1),
//           DateTime(2024, 11, 2),
//           DateTime(2024, 11, 3),
//           DateTime(2024, 11, 4),
//           DateTime(2024, 11, 5),
//         ]);
//       });
//       test('Daily recurrence daylight savings fall edge', () {
//         final startDate = DateTime(2024, 11, 3);
//         final endDate = DateTime(2024, 11, 5);
//         final dates = recurrenceDates(startDate, endDate, Frequency.daily);

//         expect(dates, [
//           DateTime(2024, 11, 3),
//           DateTime(2024, 11, 4),
//           DateTime(2024, 11, 5),
//         ]);
//       });

//       test('Daily recurrence daylight savings spring', () {
//         final startDate = DateTime(2025, 3, 8);
//         final endDate = DateTime(2025, 3, 12);
//         final dates = recurrenceDates(startDate, endDate, Frequency.daily);

//         expect(dates, [
//           DateTime(2025, 3, 8),
//           DateTime(2025, 3, 9),
//           DateTime(2025, 3, 10),
//           DateTime(2025, 3, 11),
//           DateTime(2025, 3, 12),
//         ]);
//       });

//       test('Daily recurrence edge - leap year', () {
//         // test for switching between months/february weirdness
//         final startDate = DateTime(2024, 2, 25);
//         final endDate = DateTime(2024, 3, 4);
//         final dates = recurrenceDates(startDate, endDate, Frequency.daily);

//         expect(dates, [
//           DateTime(2024, 2, 25),
//           DateTime(2024, 2, 26),
//           DateTime(2024, 2, 27),
//           DateTime(2024, 2, 28),
//           DateTime(2024, 2, 29),
//           DateTime(2024, 3, 1),
//           DateTime(2024, 3, 2),
//           DateTime(2024, 3, 3),
//           DateTime(2024, 3, 4),
//         ]);
//       });
//     });
//     group('weekly', () {
//       test('Weekly recurrence with fall savings', () {
//         final startDate = DateTime(2024, 11, 1);
//         final endDate = DateTime(2024, 12, 1);
//         final dates = recurrenceDates(startDate, endDate, Frequency.weekly);

//         expect(dates, [
//           DateTime(2024, 11, 1),
//           DateTime(2024, 11, 8),
//           DateTime(2024, 11, 15),
//           DateTime(2024, 11, 22),
//           DateTime(2024, 11, 29),
//         ]);
//       });
//       test('Weekly recurrence month edge w/ spring savings', () {
//         final startDate = DateTime(2025, 2, 22);
//         final endDate = DateTime(2025, 3, 31);
//         final dates = recurrenceDates(startDate, endDate, Frequency.weekly);

//         expect(dates, [
//           DateTime(2025, 2, 22),
//           DateTime(2025, 3, 1),
//           DateTime(2025, 3, 8),
//           DateTime(2025, 3, 15),
//           DateTime(2025, 3, 22),
//           DateTime(2025, 3, 29),
//         ]);
//       });
//       test('Weekly recurrence edge case end date is included', () {
//         final startDate = DateTime(2024, 12, 2);
//         final endDate = DateTime(2024, 12, 16);
//         final dates = recurrenceDates(startDate, endDate, Frequency.weekly);

//         expect(dates, [
//           DateTime(2024, 12, 2),
//           DateTime(2024, 12, 9),
//           DateTime(2024, 12, 16),
//         ]);
//       });
//       test('Weekly recurrence edge case, day is 31', () {
//         final startDate = DateTime(2024, 12, 31);
//         final endDate = DateTime(2025, 3, 14);
//         final dates = recurrenceDates(startDate, endDate, Frequency.weekly);

//         expect(dates, [
//           DateTime(2024, 12, 31),
//           DateTime(2025, 1, 7),
//           DateTime(2025, 1, 14),
//           DateTime(2025, 1, 21),
//           DateTime(2025, 1, 28),
//           DateTime(2025, 2, 4),
//           DateTime(2025, 2, 11),
//           DateTime(2025, 2, 18),
//           DateTime(2025, 2, 25),
//           DateTime(2025, 3, 4),
//           DateTime(2025, 3, 11),
//         ]);
//       });
//     });

//     group('monthly', () {
//       test('Monthly recurrence last day of month leap year', () {
//         final startDate = DateTime(2024, 1, 31);
//         final endDate = DateTime(2024, 6, 1);
//         final dates = recurrenceDates(startDate, endDate, Frequency.monthly);

//         expect(dates, [
//           DateTime(2024, 1, 31),
//           DateTime(2024, 2, 29),
//           DateTime(2024, 3, 31),
//           DateTime(2024, 4, 30),
//           DateTime(2024, 5, 31),
//         ]);
//       });
//       test('Monthly recurrence 30th of month', () {
//         final startDate = DateTime(2024, 6, 30);
//         final endDate = DateTime(2024, 8, 22);
//         final dates = recurrenceDates(startDate, endDate, Frequency.monthly);

//         expect(dates, [DateTime(2024, 6, 30), DateTime(2024, 7, 30)]);
//       });
//       test('Monthly recurrence 1st of month, year change', () {
//         final startDate = DateTime(2024, 11, 1);
//         final endDate = DateTime(2025, 2, 16);
//         final dates = recurrenceDates(startDate, endDate, Frequency.monthly);

//         expect(dates, [
//           DateTime(2024, 11, 1),
//           DateTime(2024, 12, 1),
//           DateTime(2025, 1, 1),
//           DateTime(2025, 2, 1),
//         ]);
//       });
//       test('Monthly recurrence last day of month year change', () {
//         final startDate = DateTime(2024, 11, 30);
//         final endDate = DateTime(2025, 3, 16);
//         final dates = recurrenceDates(startDate, endDate, Frequency.monthly);

//         expect(dates, [
//           DateTime(2024, 11, 30),
//           DateTime(2024, 12, 30),
//           DateTime(2025, 1, 30),
//           DateTime(2025, 2, 28),
//         ]);
//       });
//       test('Monthly recurrence year change daylight savings', () {
//         final startDate = DateTime(2024, 11, 3);
//         final endDate = DateTime(2025, 2, 16);
//         final dates = recurrenceDates(startDate, endDate, Frequency.monthly);

//         expect(dates, [
//           DateTime(2024, 11, 3),
//           DateTime(2024, 12, 3),
//           DateTime(2025, 1, 3),
//           DateTime(2025, 2, 3),
//         ]);
//       });
//     });

//     group('annually', () {
//       test('Annually recurrence, leap year', () {
//         final startDate = DateTime(2020, 2, 29);
//         final endDate = DateTime(2028, 2, 28);
//         final dates = recurrenceDates(startDate, endDate, Frequency.annually);

//         expect(dates, [
//           DateTime(2020, 2, 29),
//           DateTime(2021, 2, 28),
//           DateTime(2022, 2, 28),
//           DateTime(2023, 2, 28),
//           DateTime(2024, 2, 28),
//           DateTime(2025, 2, 28),
//           DateTime(2026, 2, 28),
//           DateTime(2027, 2, 28),
//         ]);
//       });
//       test('Annually recurrence, daylight savings', () {
//         final startDate = DateTime(2020, 3, 9);
//         final endDate = DateTime(2028, 3, 28);
//         final dates = recurrenceDates(startDate, endDate, Frequency.annually);

//         expect(dates, [
//           DateTime(2020, 3, 9),
//           DateTime(2021, 3, 9),
//           DateTime(2022, 3, 9),
//           DateTime(2023, 3, 9),
//           DateTime(2024, 3, 9),
//           DateTime(2025, 3, 9),
//           DateTime(2026, 3, 9),
//           DateTime(2027, 3, 9),
//           DateTime(2028, 3, 9),
//         ]);
//       });
//     });
//   });
// }
