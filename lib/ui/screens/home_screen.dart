import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/calendar_controller.dart';
import '../widgets/month_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cell Calendar App'),
      ),
      body: GetBuilder<CalendarController>( // Rebuild when controller changes
        init: Get.find<CalendarController>(), 
        builder: (controller) {
          return MonthView(
            selectedDate: controller.selectedDate, 
            events: controller.events, 
            onDayTapped: controller.onDayTapped,
          );
        },
      ),
    );
  }
}