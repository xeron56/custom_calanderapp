import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String eventName;
  final DateTime eventDate;
  final Color eventBackgroundColor;

  CalendarEvent({
    required this.id,
    required this.eventName,
    required this.eventDate,
    required this.eventBackgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventDate': Timestamp.fromDate(eventDate), // Store as Timestamp in Firestore
      'eventBackgroundColor': eventBackgroundColor.value,
    };
  }

  factory CalendarEvent.fromMap(String id, Map<String, dynamic> map) {
    return CalendarEvent(
      id: id,
      eventName: map['eventName'] ?? '',
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      eventBackgroundColor: Color(map['eventBackgroundColor']),
    );
  }
}