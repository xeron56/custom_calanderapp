import 'package:flutter/material.dart';

import '../../models/event.dart';

class EventWidget extends StatelessWidget {
  final CalendarEvent event;

  const EventWidget({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: event.eventBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        event.eventName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.0,
        ),
        overflow: TextOverflow.ellipsis, 
      ),
    );
  }
}