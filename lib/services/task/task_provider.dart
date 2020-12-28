import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/tasks_tab.dart';
import 'package:greenapp/services/task/base_task_provider.dart';
import 'package:greenapp/services/task/http_task_provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class TaskProvider implements BaseTaskProvider {
  HttpTaskProvider _httpTaskProvider;
  VoidCallback logoutCallback;

  TaskProvider(this.logoutCallback) {
    this.logoutCallback = logoutCallback;
    _setHttpProvider();
  }

  @override
  Future<int> createTask(List<Object> objects, Task task) async {
    final user = _auth.currentUser;
    task.createdBy = getUserId();
    task.assignee = null;
    debugPrint("Set user id: " + getUserId());
    return _httpTaskProvider.createTask(objects, task);
  }

  @override
  Future<Task> getTask(int id) {
    return _httpTaskProvider.getTask(id);
  }

  @override
  Future<List<Task>> getTaskList(int lastTaskId, TaskStatus taskStatus,
      String searchString, String assignee, int amount) {
    return _httpTaskProvider.getTaskList(
        lastTaskId, taskStatus, searchString, assignee, amount);
  }

  @override
  Future<bool> updateTask(Task task) {
    return _httpTaskProvider.updateTask(task);
  }

  Future<void> _setHttpProvider() async {
    _httpTaskProvider = HttpTaskProvider(logoutCallback);
  }

  @override
  Future<NetworkImage> getAttachment(int attachId) {
    return _httpTaskProvider.getAttachment(attachId);
  }

  @override
  Future<bool> updateTaskWithAttachments(
      List<Object> objects, Task task) async {
    task.assignee = _auth.currentUser.uid;
    return _httpTaskProvider.updateTaskWithAttachments(objects, task);
  }

  @override
  Future<bool> patchTaskStatus(Task task, TaskStatus taskStatus) {
    return _httpTaskProvider.patchTaskStatus(task, taskStatus);
  }

  @override
  Future<bool> voteForTask(Task task, VoteChoice voteChoice) {
    return _httpTaskProvider.voteForTask(task, voteChoice);
  }

  @override
  String getToken() {
    String token;
    _auth.currentUser.getIdToken(false).then((value) => token = value);
    return token;
  }

  String getUserId() {
    return _auth.currentUser.uid;
  }
}
