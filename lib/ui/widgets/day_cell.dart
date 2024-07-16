import 'package:flutter/material.dart';

import '../../models/event.dart';
import 'event_widget.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => onTap(date),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              color: isToday ? Colors.grey[300] : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return EventWidget(event: events[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}