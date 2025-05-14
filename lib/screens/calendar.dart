// ignore_for_file: avoid_print

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef Week = List<DateTime>;

// TODO: aware of bug when selecting March 10, 2025

/// Displays an interactive calendar that lets the user view a schedule of chores
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late Member _currUser;
  // All of the user's chore instances
  late List<ChoreInst> _chores;
  // Track the user's current selection of chores
  DateSelection _rangeSelection = DateSelection.week;
  // The date the user has selected
  late DateTime _selectedDate;
  // List of weeks (each is a List of date time)
  late List<Week> _swipeDates;
  // Controls swiping for the list of weeks
  late PageController _controller;
  // The month of the days being displayed
  late String _currMonth;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _currUser = providerRef.currentUser;
    _chores = providerRef.getMemberChoreInstances(_currUser.id);
    final now = DateTime.now();
    // select today as the date!
    _selectedDate = now;
    // now get a list of all dates +- 1 month for user to swipe through
    // list should be separated by week, so it's actually a list of lists
    _swipeDates = getSurroundingDates(now);
    final indexOfNow = _swipeDates.indexWhere(
      (week) => week.where((day) => isSameDay(day, now)).isNotEmpty,
    );
    _controller = PageController(initialPage: indexOfNow);
    _currMonth = getNameOfMonth(now.month);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
                  _selectDateRange(spacing),
                  // Display Calendar dates for date range
                  _displayCalendar(width, spacing, height),
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
  Widget _selectDateRange(double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing / 3),
      child: Row(
        children: [
          Text('Selected date range: ', style: DivvyTheme.bodyGrey),
          SizedBox(width: spacing / 2),
          _rangeSelector(spacing),
        ],
      ),
    );
  }

  /// Display a box the user uses to select a date range
  Widget _rangeSelector(double spacing) {
    return IntrinsicWidth(
      child: Container(
        height: 45,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: DivvyTheme.standardBox,
        child: DropdownButtonFormField(
          value: _rangeSelection,
          borderRadius: BorderRadius.circular(15),
          elevation: 3,
          decoration: const InputDecoration(border: InputBorder.none),
          dropdownColor: DivvyTheme.background,
          iconEnabledColor: DivvyTheme.mediumGreen,
          items:
              DateSelection.values
                  .map<DropdownMenuItem<DateSelection>>(
                    (DateSelection sel) => DropdownMenuItem<DateSelection>(
                      value: sel,
                      child: Text(
                        sel.name,
                        style: DivvyTheme.smallBoldMedGreen,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (DateSelection? value) async {
            if (value != null) {
              // have user pick date
              if (value == DateSelection.day) {
                _pickDate(context);
              } else {
                // or choose now
                _updateCalendar(DateTime.now(), value);
              }
            }
          },
        ),
      ),
    );
  }

  /// Allows user to pick a date to display
  void _pickDate(BuildContext context) async {
    // Only allow user to pick dates within a year.
    final minDate = DateTime.now().subtract(Duration(days: 365));
    final maxDate = DateTime.now().add(Duration(days: 365));
    DateTime selectedDate = _selectedDate;
    await showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            // The Bottom margin is provided to align the popup above the system
            // navigation bar.
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // Provide a background color for the popup.
            color: CupertinoColors.systemBackground.resolveFrom(context),
            // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(
              top: false,
              child: CupertinoDatePicker(
                initialDateTime: _selectedDate,
                mode: CupertinoDatePickerMode.date,
                use24hFormat: false,
                minimumDate: minDate,
                maximumDate: maxDate,
                // This shows day of week alongside day of month
                showDayOfWeek: true,
                // This is called when the user changes the date.
                onDateTimeChanged: (DateTime newDate) {
                  selectedDate = newDate;
                },
              ),
            ),
          ),
    );
    _updateCalendar(selectedDate, DateSelection.day);
  }

  /// Updates week and dates shown
  void _updateCalendar(DateTime date, DateSelection sel) {
    final dates = getSurroundingDates(date);
    final initPage = dates.indexWhere(
      (week) => week.where((day) => isSameDay(day, date)).isNotEmpty,
    );
    final month = getNameOfMonth(date.month);
    // Update calendar to show chosen range
    setState(() {
      // update the selected date!
      _selectedDate = date;
      // update date range
      _swipeDates = dates;
      _currMonth = month;
      _rangeSelection = sel;
    });
    // update current page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpToPage(initPage);
    });
  }

  /// Shows a 60-day range of swipable dates (if the curent selection is a week)
  /// Or a single week's date (if user has chosen a single date).
  Widget _displayCalendar(double width, double spacing, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_currMonth, style: DivvyTheme.smallBoldMedGreen),
        SizedBox(height: spacing / 2),
        SizedBox(
          height: height * 0.12,
          child:
          // Display current month
          PageView.builder(
            controller: _controller,
            itemCount: _swipeDates.length,
            onPageChanged:
                (int page) => setState(() {
                  final week = _swipeDates[page];
                  _currMonth = getNameOfMonth(week.first.month);
                }),
            itemBuilder: (context, index) {
              final week = _swipeDates[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ), // Spacing between pages
                child: _weekDayDisplay(width, spacing, week, height),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Displays row of selectable dates for the inputted week
  Widget _weekDayDisplay(
    double width,
    double spacing,
    Week week,
    double height,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          week.map((date) {
            return _dateTile(date, width / 10, spacing, height);
          }).toList(),
    );
  }

  /// Displays a tile for the selected date.
  Widget _dateTile(DateTime date, double width, double spacing, double height) {
    // True if current date is selected
    bool isSelected = isSameDay(date, _selectedDate);
    // True if current date has chores
    bool hasChores =
        _chores.where((chore) => isSameDay(chore.dueDate, date)).isNotEmpty;
    return InkWell(
      onTap: () => setState(() => _selectedDate = date),
      child: IntrinsicHeight(
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
          '${getNameOfWeekday(_selectedDate.weekday)}, ${getFormattedDate(_selectedDate)}:',
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

enum DateSelection { week, day }

extension DateSelectionInfo on DateSelection {
  String get name => switch (this) {
    DateSelection.week => 'This week',
    DateSelection.day => 'Selected date',
  };
}
