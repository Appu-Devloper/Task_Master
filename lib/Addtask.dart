import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'control.dart';

class AddTaskScreen extends StatelessWidget {
  final TaskController taskController = Get.find();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        picked = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
      dateTimeController.text = picked.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Add Task',
            style: TextStyle(fontWeight: FontWeight.w500),
          )),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            SizedBox(height: 20.0),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: IgnorePointer(
                child: TextField(
                  controller: dateTimeController,
                  decoration: InputDecoration(
                    labelText: 'Date and Time',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    dateTimeController.text.isNotEmpty) {
                  Task newTask = Task(
                    title: titleController.text,
                    dateTime: DateTime.parse(dateTimeController.text),
                  );
                  taskController.addTask(newTask);
                  Get.back();
                } else {
                  Get.snackbar(
                    'Error',
                    'Please enter task title and date time',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
