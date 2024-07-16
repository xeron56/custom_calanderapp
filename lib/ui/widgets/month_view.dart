import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/calendar_controller.dart';
import 'day_cell.dart';

class MonthView extends StatefulWidget {
  final DateTime selectedDate;

  final ValueChanged<DateTime> onDayTapped;

  const MonthView(
      {Key? key, required this.selectedDate, required this.onDayTapped})
      : super(key: key);

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  final PageController _pageController = PageController(
    initialPage: DateTime.now().month - 1,
  );
  int _currentPage = DateTime.now().month - 1;

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
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final month = index + 1;
              return _buildCalendarGrid(month);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearHeader() {
    final displayedDate = DateTime(widget.selectedDate.year, _currentPage + 1);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            },
          ),
          Text(
            DateFormat.yMMMM().format(displayedDate),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            },
          ),
        ],
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
      itemCount: daysInMonth + (firstWeekday - 1),
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Center(
              child: Text(
                DateFormat('EEE').format(DateTime(
                    widget.selectedDate.year, month, index - firstWeekday + 2)),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
        final int day = index - (firstWeekday - 2);
        final DateTime date = DateTime(widget.selectedDate.year, month, day);
        final bool isToday = isSameDay(date, DateTime.now());
        final calendarController = Get.find<CalendarController>();

        return DayCell(
          date: date,

          events: calendarController.getEventsForDay(date),
          isSelected: isSameDay(date, widget.selectedDate),
          isToday: isToday,
          //onTap: widget.onDayTapped,
          onTap: (tappedDate) {
            widget.onDayTapped(tappedDate); // Update the selected date
            Get.find<CalendarController>().showEventDialog(context, tappedDate);
          },
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
