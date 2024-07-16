import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    showEventDialog(Get.context!, date);
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

  void showEventDialog(BuildContext context, DateTime selectedDate) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Text(
              DateFormat.yMMMMd().format(selectedDate),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: getEventsForDay(selectedDate).length,
                  itemBuilder: (context, index) {
                    final event = getEventsForDay(selectedDate)[index];
                    return Dismissible(
                      key: Key(event.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        deleteEvent(event.id);

                        Get.snackbar(
                          'Event Deleted',
                          '${event.eventName} deleted',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: event.eventBackgroundColor,
                        ),
                        title: Text(event.eventName),
                        onTap: () {
                          // Handle tapping on the event tile, e.g., open an edit dialog
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showAddEventDialog(context: context, selectedDate: selectedDate);
              },
              child: const Text("Add Event"),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Modified _showAddEventDialog
  void _showAddEventDialog(
      {required BuildContext context, required DateTime selectedDate}) {
    final _formKey = GlobalKey<FormState>();
    String _eventName = '';
    Color _eventColor = Colors.blue;

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
                  id: '',
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