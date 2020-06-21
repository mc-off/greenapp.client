import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/task_row_item.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:http/http.dart' as http;

class TaskList extends StatefulWidget {
  final BaseTaskProvider baseTaskProvider;
  final List<Task> taskList;

  TaskList({this.baseTaskProvider, this.taskList});

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  TaskLoadStatus loadStatus = TaskLoadStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<Task> tasks;
  int lastTaskID;

  @override
  void initState() {
    tasks = widget.taskList;
    lastTaskID = widget.taskList.last.id;
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: false,
          child: NotificationListener<ScrollNotification>(
              onNotification: _onNotification, child: _listViewBuilder())),
      color: CupertinoColors.systemBackground,
    );
  }

  Widget _listViewBuilder() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskRowItem(task: tasks[index]);
      },
    );
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
        if (loadStatus != null && loadStatus == TaskLoadStatus.STABLE) {
          loadStatus = TaskLoadStatus.LOADING;
          widget.baseTaskProvider.getTasks(lastTaskID).then((newTaskList) {
            lastTaskID = newTaskList.last.id;
            loadStatus = TaskLoadStatus.STABLE;
            setState(() => tasks.addAll(newTaskList));
          });
        }
      }
    }
    return true;
  }

  Future<List<Task>> getTasksList() async {
    debugPrint("getTasksList");
    http.Response response = await http.post(
      "https://greenapp-gateway.herokuapp.com/task-provider/tasks",
      headers: <String, String>{
        'Authorization':
            "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzemIwOTkyM0BjdW9seS5jb20iLCJleHAiOjE1OTI3NjQ0MjIsImlhdCI6MTU5Mjc0NjQyMn0.ouTIaGc6hLPE4aKa-TCj_LW2ovkHQ-kCfWhgdiaz9Q9ED14m5uwPH0vczZ82HO9fMcEieZ1va4ZWrs8wJdFhMw",
        'Content-type': 'application/json',
      },
      body: json.encode({
        'status': EnumToString.parse(TaskStatus.CREATED),
        "limit": 10,
        "offset": 0
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      List<Task> taskList = [];
      for (Map i in t) {
        taskList.add(Task.fromJson(i));
      }
      return taskList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      throw Exception('Failed to parse tasks');
    }
  }
}
