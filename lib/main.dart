import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Addtask.dart';
import 'Edit.dart';
import 'control.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  // await initializeservice();
  await LocalNotifications.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskController taskController = Get.put(TaskController());
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode; // Add FocusNode

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(); // Initialize FocusNode
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  List<Task> _searchedTasks = [];

  void _filterTasks(String query) {
    List<Task> _searchResult = taskController.tasks
        .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _searchedTasks = _searchResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Task Master',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            _searchFocusNode
                .unfocus(); // Unfocus when tapping outside the field
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 55,
                  child: TextField(
                    focusNode: _searchFocusNode, // Assign FocusNode
                    controller: _searchController,
                    onChanged: _filterTasks,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                          borderRadius: BorderRadius.circular(30)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterTasks('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  List<Task> sortedTasks = taskController.tasks.toList();
                  sortedTasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));

                  return ListView.builder(
                    itemCount: _searchController.text.isNotEmpty
                        ? _searchedTasks.length
                        : sortedTasks.length,
                    itemBuilder: (context, index) {
                      Task task = _searchController.text.isNotEmpty
                          ? _searchedTasks[index]
                          : sortedTasks[index];
                      return Card(
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                            DateFormat('MMM d, y - hh:mm a')
                                .format(task.dateTime),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Get.to(
                                      EditTaskScreen(task: task, index: index),
                                      fullscreenDialog: true);
                                },
                              ),
                              Checkbox(
                                activeColor: Colors.green,
                                value: task.isCompleted,
                                onChanged: (value) {
                                  taskController.updateTaskCompletion(
                                      index, value!);
                                },
                              ),
                            ],
                          ),
                          onLongPress: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                title: Text("Delete Task"),
                                content: Text(
                                    "Are you sure you want to delete this task?"),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      taskController.deleteTask(index);
                                      Navigator.pop(context);
                                    },
                                    isDestructiveAction: true,
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        label: Text("Add Task"),
                        onPressed: () {
                          Get.to(AddTaskScreen(), fullscreenDialog: true);
                        },
                        icon: Icon(CupertinoIcons.add_circled),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
