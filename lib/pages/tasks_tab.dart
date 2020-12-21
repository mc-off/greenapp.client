import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/task_list.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/widgets/placeholder_content.dart';
import 'package:http/http.dart' as http;


final int INITIAL_ID_FOR_TASKS = 0;

class TasksTab extends StatefulWidget {
  TasksTab({this.baseTaskProvider});

  @required
  final BaseTaskProvider baseTaskProvider;

  @override
  _TasksTabState createState() {
    return _TasksTabState();
  }
}

class _TasksTabState extends State<TasksTab> {
  @override
  Widget build(BuildContext context) {
    return new NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Tasks'),
            ),
          ];
        },
        body: FutureBuilder(
            future: widget.baseTaskProvider.getTasks(INITIAL_ID_FOR_TASKS),
            builder: (context, projectSnapshot) {
              debugPrint(EnumToString.parse(projectSnapshot.connectionState));
              if (projectSnapshot.hasError)
                return PlaceHolderContent(
                  title: "Problem Occurred",
                  message: "Internet not connect try again",
                  tryAgainButton: _tryAgainButtonClick,
                );
              switch (projectSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return _showCircularProgress();
                case ConnectionState.done:
                  return TaskList(
                    baseTaskProvider: widget.baseTaskProvider,
                    taskList: projectSnapshot.data,
                  );
                default:
                  return _showCircularProgress();
              }
            }));
  }

  _tryAgainButtonClick(bool _) => setState(() {});

  Widget _showCircularProgress() {
    return Center(child: CupertinoActivityIndicator());
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
