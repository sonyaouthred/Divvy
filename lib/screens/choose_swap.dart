import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/calendar.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Allow the user to add/edit a model, saves on close.
class ChooseSwap extends StatefulWidget {
  final ChoreID choreID;
  const ChooseSwap({super.key, required this.choreID});

  @override
  State<ChooseSwap> createState() => _ChooseSwapState();
}

class _ChooseSwapState extends State<ChooseSwap> {
  /// The ChoreID for the superclass of chore the user can pick from
  late final ChoreID _choreID;

  /// The list of chore instances available to be swapped.
  /// Must be this user's and incomplete.
  late List<ChoreInst> _availableChores;

  /// the chore the user has selected to swap.
  late ChoreInst? _selected;
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
    _choreID = widget.choreID;
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _availableChores = providerRef.getMemberSwappableChores(choreID: _choreID);
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
    _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double spacing = width * 0.05;
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text('Select a chore', style: DivvyTheme.largeHeaderBlack),
        backgroundColor: DivvyTheme.background,
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
            onTap: () => _popBack(context, false),
            child: SizedBox(width: 45, height: 45, child: Icon(Icons.close)),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult:
            (didPop, result) => {
              if (!didPop) {_popBack(context, false)},
            },
        child: SizedBox.expand(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: DivvyTheme.background,
                ),
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: SingleChildScrollView(
                  child: Consumer<DivvyProvider>(
                    builder: (context, provider, child) {
                      // refresh data from provider
                      _availableChores = provider.getMemberSwappableChores(
                        choreID: _choreID,
                      );
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display date range
                          _selectDateRange(spacing),
                          // Display Calendar dates for date range
                          _displayCalendar(width, spacing, height),
                          SizedBox(height: spacing),
                          // Display chores on current date
                          _displayChores(spacing),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: _swapButon(spacing, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Widgets ///////////////////////////////

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
    final minDate = DateTime.now().subtract(Duration(days: 180));
    final maxDate = DateTime.now().add(Duration(days: 180));
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
        _availableChores
            .where((chore) => isSameDay(chore.dueDate, date))
            .isNotEmpty;
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
                getLetterForWeekday(date.weekday),
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
    final choreList = _availableChores.where(
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
                choreList
                    .map(
                      (chore) => ChoreTile(
                        choreInst: chore,
                        customAction: _selectInstance,
                        trailing: Icon(
                          _selected == chore
                              ? Icons.circle
                              : Icons.circle_outlined,
                          color: DivvyTheme.mediumGreen,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  /// Triggers the swap action
  Widget _swapButon(double spacing, BuildContext context) => Container(
    height: 60,
    width: 60,
    margin: EdgeInsets.symmetric(
      horizontal: spacing * 2,
      vertical: spacing * 3,
    ),
    child: InkWell(
      onTap: () => _popBack(context, true),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        decoration: DivvyTheme.completeBox(true),
        child: Icon(Icons.check, color: DivvyTheme.background, size: 40),
      ),
    ),
  );

  ////////////////////////////// Util Functions ///////////////////////////////

  /// Either select or deselect the passed chore instance
  void _selectInstance(ChoreInst choreInst) {
    setState(() {
      if (_selected == choreInst) {
        _selected = null;
      } else {
        _selected = choreInst;
      }
    });
  }

  /// Add new project, updating provider. If fields are empty, do nothing.
  void _popBack(BuildContext context, bool swap) async {
    if (!context.mounted) return;
    if (!swap) {
      // User doesn't want to swap, just pop back.
      Navigator.pop(context);
      return;
    }
    if (_selected == null) {
      await showErrorMessage(
        context,
        'No chore selected',
        'Please choose a chore to swap.',
      );
      return;
    }
    Navigator.pop(context, _selected!.id);
  }
}
