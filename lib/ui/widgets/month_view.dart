import 'package:custom_calanderapp/ui/widgets/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/event.dart'; // Make sure this import is correct

class MonthView extends StatefulWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onDayTapped;

  const MonthView({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDayTapped,
  }) : super(key: key);

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  final PageController _pageController = PageController(
    initialPage: DateTime.now().month - 1, // Start with the current month
  );

  @override
  void dispose() {
    _pageController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthYearHeader(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: 12, // 12 months
            itemBuilder: (context, index) {
              final month = index + 1;
              return _buildCalendarGrid(month);
            },
            onPageChanged: (index) {
              // You can update the selected date in the controller here if needed
              // But since the user usually selects a specific day, it's probably
              // not necessary to track month changes here.
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        DateFormat.yMMMM().format(widget.selectedDate),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(int month) {
    final DateTime firstDayOfMonth =
        DateTime(widget.selectedDate.year, month, 1);
    final int daysInMonth = DateTime(firstDayOfMonth.year, month + 1, 0).day;
    final int firstWeekday = firstDayOfMonth.weekday;

    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: daysInMonth + (firstWeekday - 1), // Add days for padding
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox.shrink(); // Padding for the first week
        }
        final int day = index - (firstWeekday - 2);
        final DateTime date = DateTime(widget.selectedDate.year, month, day);
        final bool isToday = isSameDay(date, DateTime.now());

        return DayCell(
          date: date,
          events: widget.events.where((event) => isSameDay(event.eventDate, date)).toList(),
          isSelected: isSameDay(date, widget.selectedDate),
          isToday: isToday,
          onTap: widget.onDayTapped,
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}