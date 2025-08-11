import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('task'.tr),
      ),
      body: Center(
        child: Text(
          'task_section_coming_soon'.tr,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
