// ignore_for_file: avoid_print

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Member _currUser;
  late List<ChoreInst> _chores;
  final _rangeSelection = DateSelection.week;
  late List<DateTime> _dates;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _currUser = providerRef.currentUser;
    _chores = providerRef.getMemberChoreInstances(_currUser.id);
    final now = DateTime.now();
    final sunday = now.subtract(Duration(days: now.weekday));
    // get list of dates in the current week.
    _dates = List.generate(
      7,
      (i) => DateTime(sunday.year, sunday.month, sunday.day + i),
    );
    _selectedDate = now;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // refresh data from provider
        _chores = provider.getMemberChoreInstances(_currUser.id);
        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display date range
                  _selectDateRange(),
                  SizedBox(height: spacing / 2),
                  // Display Calendar dates for date range
                  _displayCalendar(width, spacing),
                  SizedBox(height: spacing),
                  // Display chores on current date
                  _displayChores(spacing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Allows user to select a date range
  Widget _selectDateRange() {
    return InkWell(
      onTap: () => _changeDateRange(context, DateSelection.month),
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            Text('Selected date range: ', style: DivvyTheme.bodyGrey),
            Text(
              _rangeSelection == DateSelection.week
                  ? 'This week'
                  : 'This month',
              style: DivvyTheme.smallBoldMedGreen,
            ),
          ],
        ),
      ),
    );
  }

  /// Displays weekly or monthly calendar
  Widget _displayCalendar(double width, double spacing) {
    if (_rangeSelection == DateSelection.month) return Placeholder();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          _dates.map((date) {
            return _dateTile(date, width / 10, spacing);
          }).toList(),
    );
  }

  /// Displays a tile for the selected date.
  Widget _dateTile(DateTime date, double width, double spacing) {
    // True if current date is selected
    bool isSelected = isSameDay(date, _selectedDate);
    // True if current date has chores
    bool hasChores =
        _chores.where((chore) => isSameDay(chore.dueDate, date)).isNotEmpty;
    return InkWell(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        decoration: DivvyTheme.oval(
          isSelected ? DivvyTheme.mediumGreen : DivvyTheme.white,
        ),
        width: width,
        child: Column(
          children: [
            SizedBox(height: spacing / 2),
            // Display weekday letter
            Text(
              _getLetterForWeekday(date.weekday),
              style:
                  isSelected
                      ? DivvyTheme.smallBoldMedWhite
                      : DivvyTheme.smallBoldMedGreen,
            ),
            // Display day of month letter
            Text(
              date.day.toString(),
              style:
                  isSelected
                      ? DivvyTheme.largeBoldMedWhite
                      : DivvyTheme.largeBoldMedGreen,
            ),
            SizedBox(height: spacing / 4),
            // Shows contrasting bubble if the date has chores on it.
            Container(
              decoration: DivvyTheme.profileCircle(
                hasChores
                    ? isSelected
                        ? DivvyTheme.background
                        : DivvyTheme.mediumGreen
                    : isSelected
                    ? DivvyTheme.mediumGreen
                    : DivvyTheme.background,
              ),
              height: 8,
            ),
            SizedBox(height: spacing / 2),
          ],
        ),
      ),
    );
  }

  /// Displays the list of chores for the selected date.
  Widget _displayChores(double spacing) {
    final choreList = _chores.where(
      (chore) => isSameDay(chore.dueDate, _selectedDate),
    );
    // Handle empty chore list
    if (choreList.isEmpty) {
      return Center(
        child: Text('Nothing to see here!', style: DivvyTheme.bodyGrey),
      );
    }
    // Nonempty chore list, display results
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // display dates
        Text(
          '${getNameOfWeekday(_selectedDate.weekday)}, ${DateFormat.yMMMMd('en_US').format(_selectedDate)}:',
          style: DivvyTheme.bodyBoldBlack,
        ),
        // display chores
        Padding(
          padding: EdgeInsets.all(spacing / 2),
          child: Column(
            children:
                choreList.map((chore) => ChoreTile(choreInst: chore)).toList(),
          ),
        ),
      ],
    );
  }

  //////////////////////// Util Functions ////////////////////////

  void _changeDateRange(BuildContext context, DateSelection newRange) {
    print('changing range');
    // will need to update the selected range
    // and the list of dates
  }

  /// Returns a one-letter string for the current weekday
  String _getLetterForWeekday(int weekday) => switch (weekday) {
    1 => 'M',
    2 => 'T',
    3 => 'W',
    4 => 'Th',
    5 => 'F',
    6 => 'S',
    7 => 'S',
    int() => '?',
  };
}

enum DateSelection { week, month }
