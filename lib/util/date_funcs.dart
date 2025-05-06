import 'package:divvy/models/chore.dart';
import 'package:jiffy/jiffy.dart';

/// Formats a DateTime object into a string representation.
/// Parameters:
///  - date: The DateTime object to format
/// Returns: String in the format "mm/dd/yyyy"
String formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

/// Formats a DateTime object into a short date string.
/// Parameters:
///  - date: The DateTime object to format
/// Returns: String in the format "mm/dd"
String formatDayMonth(DateTime date) {
  return '${date.month}/${date.day}';
}

/// Generates dates for recurring expenses based on frequency.
/// Parameters:
///  - frequency: How often the expense should recur (Daily, Weekly, Monthly)
/// Returns: List of DateTime objects representing all occurrence dates. Only generates
/// for a 90-day period
/// Expected behavior:
///   - monthly: repeat once monthly on the same date for 3 months
///   - daily: repeat every day for 90 days + start date
///   - weekly: repeat weekly on the [daysOfWeek] weekdays for a 90 day period
List<DateTime> getDateList(
  Frequency frequency,
  List<int> daysOfWeek,
  DateTime startDate,
) {
  final List<DateTime> dates = [];
  DateTime endDate = startDate.add(const Duration(days: 90));
  switch (frequency) {
    case Frequency.monthly:
      // End date should be adjusted to only be three months after.
      endDate = Jiffy.parseFromDateTime(startDate).add(months: 3).dateTime;
      // For a montly chore, ignore days of week
      // Check if the user has requested the last day of a given month
      bool wantLastDay = isLastDay(startDate);
      DateTime curr = startDate;
      // Add a month to the current date
      curr = Jiffy.parseFromDateTime(curr).add(months: 1).dateTime;
      curr = adjustDaylightSavings(curr);

      dates.add(startDate);

      while (curr.isBefore(endDate)) {
        dates.add(curr);
        DateTime nextMonth =
            Jiffy.parseFromDateTime(curr).add(months: 1).dateTime;
        int day = nextMonth.day;
        if (wantLastDay) {
          // gets the last day of the current month if the user wants the last
          // date of the month
          day = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
        }
        // set the current date to be the next month
        curr = DateTime(nextMonth.year, nextMonth.month, day);
        curr = adjustDaylightSavings(curr);
      }
      return dates;
    case Frequency.weekly:
      DateTime curr = startDate;
      final currDayOfWeek = curr.weekday;
      final smallestWeekday = daysOfWeek.reduce((a, b) => a < b ? a : b);
      // Verify that start date is the smallest day of the week
      if (currDayOfWeek != smallestWeekday) {
        final diff = currDayOfWeek - smallestWeekday;
        curr = curr.subtract(Duration(days: diff));
      }
      dates.addAll(getDatesFromWeek(curr, daysOfWeek, endDate));
      // advance week
      curr = curr.add(const Duration(days: 7));
      // Adjust for daylight savings (if applicable)
      curr = adjustDaylightSavings(curr);
      // Now iterate until we get to the end date!
      while (curr.isBefore(endDate)) {
        // Add the new date to the list
        dates.addAll(getDatesFromWeek(curr, daysOfWeek, endDate));
        // Add seven days (one week) until the start date is after the end date
        DateTime newDate = curr.add(const Duration(days: 7));

        // Adjust for daylight savings (if applicable)
        newDate = adjustDaylightSavings(newDate);
        curr = newDate;
      }

      // Loop exits before the end date is added, so check if it should be added
      if (startDate.difference(endDate).inDays % 7 == 0) {
        // start and end date are exactly some # of weeks apart,
        // so the end date should be included.
        dates.add(endDate);
      }
      // Now remove any extra dates... not perfect, ik
      dates.removeWhere((date) => date.isBefore(startDate));
      return dates;
    case Frequency.daily:
      // Add start date
      dates.add(startDate);
      DateTime curr = startDate;
      // need to fencepost
      curr = curr.add(const Duration(days: 1));

      // Adjust for daylight savings (if applicable)
      curr = adjustDaylightSavings(curr);
      while (curr.isBefore(endDate)) {
        // Add the new date to the list
        dates.add(curr);
        // Add a 1 to the day until the start date is after the end date
        DateTime newDate = curr.add(const Duration(days: 1));

        // Adjust for daylight savings (if applicable)
        newDate = adjustDaylightSavings(newDate);

        // reset the current
        curr = newDate;
      }
      // Loop exits before the end date is added, so make sure it is added
      dates.add(endDate);
      return dates;
  }
}

// Given a start date, returns a list of all dates in week with the same
// weekday numbers as in the inputted list.
// Does not add any days past the end date
// INVARIANT: Start date must always be the smallest day of the week in list.
// E.g. Start date Monday (3) May 5, 2025 with daysOfWeek
// [3, 5, 7] returns
// [May 7, 2025; May 9, 2025; May 11, 2025]
List<DateTime> getDatesFromWeek(
  DateTime start,
  List<int> daysOfWeek,
  DateTime end,
) {
  if (start.isAfter(end)) return [];
  final List<DateTime> res = [start];
  DateTime curr = start;
  curr = curr.add(const Duration(days: 1));
  while (curr.weekday != 1) {
    if (daysOfWeek.contains(curr.weekday)) {
      // Make sure we're not over-adding
      if (curr.isAfter(end)) break;
      res.add(curr);
    }
    curr = curr.add(const Duration(days: 1));
  }
  return res;
}

/// check if two datetime objects have the same date, ignoring time
bool compareDate(DateTime a, DateTime b) {
  return a.day == b.day && a.month == b.month && a.year == b.year;
}

// check that this date is in the range, regardless of time
bool inRange(DateTime date, List<DateTime> range) {
  return range.where((item) => compareDate(item, date)).toList().isNotEmpty;
}

/// Checks if a date is the last day of its month.
/// Parameters:
///  - date: The DateTime to check
/// Returns: true if the date is the last day of the month (31st or 28th/29th for February)
bool isLastDay(DateTime date) {
  final lastDay = DateTime(date.year, date.month + 1, 0).day;
  return date.day == lastDay;
}

/// Gets a list of dates in the current month
List<DateTime> getMonthDates(DateTime month) {
  int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

  return List.generate(
    daysInMonth,
    (index) => DateTime(month.year, month.month, index + 1),
  );
}

/// Adjusts a DateTime for daylight savings time transitions.
/// Parameters:
///  - date: The DateTime to adjust
/// Returns: Adjusted DateTime accounting for daylight savings changes
DateTime adjustDaylightSavings(DateTime date) {
  DateTime adjusted;
  // Daylight savings time is my enemy. Need to check:
  if (date.hour == 23) {
    // fall back adjustment
    adjusted = date.add(const Duration(hours: 1));
  } else if (date.hour == 1) {
    // spring forward adjustment
    adjusted = date.add(const Duration(hours: -1));
  } else {
    adjusted = date;
  }
  return adjusted;
}

/// Returns the formatted 12-hr time from a DateTime object as [HH]:[MM] [A/P]M.
String getFormattedTime(DateTime date) {
  final minuteTime =
      date.minute < 10 ? '0${date.minute}' : date.minute.toString();
  if (date.hour > 12) {
    return '${date.hour % 12}:$minuteTime PM';
  } else {
    return '${date.hour}:$minuteTime AM';
  }
}

/// Returns true if two dates are the same
bool isSameDay(DateTime d1, DateTime d2) {
  return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
}

/// Returns a one-letter string for the current weekday
String getNameOfWeekday(int weekday) => switch (weekday) {
  1 => 'Monday',
  2 => 'Tuesday',
  3 => 'Wednesday',
  4 => 'Thursday',
  5 => 'Friday',
  6 => 'Saturday',
  7 => 'Sunday',
  int() => '?',
};
