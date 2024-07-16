import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/event.dart';

class CalendarController extends GetxController {
  final _selectedDate = DateTime.now().obs;
  final RxList<CalendarEvent> _events = <CalendarEvent>[].obs;
  final _isAddingEvent = false.obs;

  DateTime get selectedDate => _selectedDate.value;

  List<CalendarEvent> getEventsForDay(DateTime date) {
    return _events.where((event) => isSameDay(event.eventDate, date)).toList();
  }

  bool get isAddingEvent => _isAddingEvent.value;

  @override
  void onInit() {
    super.onInit();
    _listenToEvents();
  }

  // Function to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void onDayTapped(DateTime date) {
    _selectedDate.value = date;
    if (!_isAddingEvent.value) {
      _showAddEventDialog(context: Get.context!, selectedDate: date);
    }
  }

  Stream<List<CalendarEvent>> _getEventStream() {
    return FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return CalendarEvent.fromMap(doc.id, doc.data());
            }).toList());
  }

  void _listenToEvents() {
    _getEventStream().listen((eventData) {
      _events.value = eventData;
    });
  }

  Future<void> addEvent(CalendarEvent event) async {
    try {
      await FirebaseFirestore.instance.collection('events').add(event.toMap());
      Get.back(); // Close the dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to add event: $e');
      print("Error adding event: $e");
    }
  }

  Future<void> updateEvent(CalendarEvent event) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .update(event.toMap());
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event');
      print("Error updating event: $e");
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event');
      print("Error deleting event: $e");
    }
  }

  void _showAddEventDialog(
      {required BuildContext context, required DateTime selectedDate}) {
    final _formKey = GlobalKey<FormState>();
    String _eventName = '';
    Color _eventColor = Colors.blue; // Default event color

    Get.dialog(
      AlertDialog(
        title: const Text('Add Event'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
                onSaved: (value) => _eventName = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Color>(
                value: _eventColor,
                decoration: const InputDecoration(labelText: 'Event Color'),
                items: [
                  DropdownMenuItem(
                    value: Colors.blue,
                    child: const Text('Blue'),
                  ),
                  DropdownMenuItem(
                    value: Colors.red,
                    child: const Text('Red'),
                  ),
                  // Add more colors as needed
                ],
                onChanged: (color) => _eventColor = color!,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Get.back();
              _isAddingEvent.value = false;
            },
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                addEvent(CalendarEvent(
                  id: '', // Firestore will auto-generate
                  eventName: _eventName,
                  eventDate: selectedDate,
                  eventBackgroundColor: _eventColor,
                ));
                _isAddingEvent.value = false;
              }
            },
          ),
        ],
      ),
    ).then((_) => _isAddingEvent.value = false);
    _isAddingEvent.value = true;
  }
}