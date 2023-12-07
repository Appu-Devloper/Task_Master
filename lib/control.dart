import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'notifications.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    fetchTasks();
  }

  void _startTimer() {
    const tenMinutes = Duration(minutes: 1);
    _timer = Timer.periodic(tenMinutes, (_) {
      _checkTasks();
    });
  }

  void _checkTasks() {
    print("hii");
    final currentTime = DateTime.now();

    for (Task task in tasks) {
      final timeDifference = task.dateTime.difference(currentTime);
      if (timeDifference.inMinutes <= 10) {
        print('Task "${task.title}" starts in 10 minutes!');
        show("${task.title} starts within 10 minutes!", "${task.title}");
      }
    }
  }

  void show(String text, String task) async {
    await LocalNotifications.showSimpleNotification(
        title: task, body: text, payload: "This is simple data");
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void fetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonString = prefs.getString('tasks');
    if (jsonString != null) {
      Iterable decoded = json.decode(jsonString);
      tasks.assignAll(decoded.map((task) => Task.fromJson(task)));
    }
  }

  void addTask(Task newTask) async {
    tasks.add(newTask);
    saveTasks();
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var encoded = json.encode(tasks.toList());
    prefs.setString('tasks', encoded);
  }

  void deleteTask(int index) async {
    tasks.removeAt(index);
    saveTasks();
  }

  void updateTaskCompletion(int index, bool isCompleted) async {
    tasks[index].isCompleted = isCompleted;
    saveTasks();
    fetchTasks();
  }
}

class Task {
  final String title;
  final DateTime dateTime;
  bool isCompleted;

  Task({
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}
