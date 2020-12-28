import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/task_item.dart';
import 'package:greenapp/pages/task_row_item.dart';
import 'package:greenapp/services/task/base_task_provider.dart';
import 'package:http/http.dart' as http;

class TaskList extends StatefulWidget {
  final BaseTaskProvider baseTaskProvider;
  final List<Task> taskList;
  final TaskStatus taskStatus;
  final VoidCallback updateCallback;
  final int lastTaskId;
  final String searchString;
  final String assignee;
  final int amount;

  TaskList(
      {this.baseTaskProvider,
      this.taskList,
      this.taskStatus,
      this.updateCallback,
      this.lastTaskId,
      this.searchString,
      this.assignee,
      this.amount});

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
      itemExtent: null,
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
            //You need to make my child interactive
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => TaskItem(
                            baseTaskProvider: widget.baseTaskProvider,
                            task: tasks[index],
                            updateCallback: widget.updateCallback,
                          )));
            },
            child: new TaskRowItem(task: tasks[index]));
      },
    );
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
        if (loadStatus != null && loadStatus == TaskLoadStatus.STABLE) {
          loadStatus = TaskLoadStatus.LOADING;
          widget.baseTaskProvider
              .getTaskList(lastTaskID, widget.taskStatus, widget.searchString,
                  widget.assignee, widget.amount)
              .then((newTaskList) {
            lastTaskID = newTaskList.last.id;
            loadStatus = TaskLoadStatus.STABLE;
            setState(() => tasks.addAll(newTaskList));
          });
        }
      }
    }
    return true;
  }
}
