import 'package:flutter/material.dart';

import '../../models/event.dart';
import 'event_widget.dart'; // Import the event widget

class DayCell extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  final bool isSelected;
  final bool isToday;
  final ValueChanged<DateTime> onTap;

  const DayCell({
    Key? key,
    required this.date,
    required this.events,
    this.isSelected = false,
    this.isToday = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(date), 
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2.0,
          ),
          color: isToday ? Colors.grey[300] : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              // Display events for this day
              ...events.map((event) => EventWidget(event: event)).toList(),
            ],
          ),
        ),
      ),
    );
  }
} 