import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import 'control.dart';

class EditTaskScreen extends StatelessWidget {
  final TaskController taskController = Get.find();
  final Task task;
  final int index;

  EditTaskScreen({required this.task, required this.index});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = task.title;
    dateTimeController.text =
        DateFormat('MMM d, y - hh:mm a').format(task.dateTime);

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Edit Task',
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
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: task.dateTime,
                  firstDate: DateTime(2021),
                  lastDate: DateTime(2025),
                );

                if (picked != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(task.dateTime),
                  );

                  if (pickedTime != null) {
                    picked = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    dateTimeController.text =
                        DateFormat('MMM d, y - hh:mm a').format(picked);
                  }
                }
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
                  Task editedTask = Task(
                    title: titleController.text,
                    dateTime: DateFormat('MMM d, y - hh:mm a')
                        .parse(dateTimeController.text),
                    isCompleted: task.isCompleted,
                  );
                  taskController.tasks[index] = editedTask;
                  taskController.saveTasks();
                  Get.back();
                } else {
                  Get.snackbar(
                    'Error',
                    'Please enter task title and date time',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
