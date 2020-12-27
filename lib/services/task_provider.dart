import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/services/http_task_provider.dart';

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
    task.createdBy = user.uid;
    task.assignee = user.uid;
    debugPrint("Set user id: " + user.uid);
    return _httpTaskProvider.createTask(objects, task);
  }

  @override
  Future<Task> getTask(int id) {
    return _httpTaskProvider.getTask(id);
  }

  @override
  Future<List<Task>> getTasks(int lastTaskId) {
    return _httpTaskProvider.getCreatedTaskList(lastTaskId);
  }

  @override
  Future<List<Task>> getTasksForUser(int lastTaskId) async {
    final user = _auth.currentUser;
    debugPrint("Set user id: " + user.uid);
    return _httpTaskProvider.getTasksForCurrentUser(lastTaskId, user.uid);
  }

  @override
  Future<bool> updateTask(Task task) {
    return _httpTaskProvider.updateTask(task);
  }

  Future<void> _setHttpProvider() async {
    _httpTaskProvider = HttpTaskProvider(logoutCallback);
  }

  @override
  Future<List<Task>> getTasksNum(int lastTaskId, int amount) {
    return _httpTaskProvider.getTasksAmount(lastTaskId, amount);
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

  Future<bool> voteForTask(Task task, VoteChoice voteChoice) {
    return _httpTaskProvider.voteForTask(
        task, voteChoice, _auth.currentUser.uid);
  }

  String getToken() {
    String token;
    _auth.currentUser.getIdToken(false).then((value) => token = value);
    return token;
  }

  String getUserId() {
    return _auth.currentUser.uid;
  }
}
