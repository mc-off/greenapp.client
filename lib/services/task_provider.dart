import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/models/user.dart';
import 'package:greenapp/services/base_auth.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/services/http_task_provider.dart';

class TaskProvider implements BaseTaskProvider {
  String _auth;
  User _user;
  BaseAuth _baseAuth;
  HttpTaskProvider _httpTaskProvider;
  VoidCallback logoutCallback;

  TaskProvider(this._baseAuth, this.logoutCallback) {
    this._baseAuth = _baseAuth;
    this.logoutCallback = logoutCallback;
    _setHttpProvider();
  }

  @override
  // TODO: implement baseAuth
  BaseAuth get baseAuth => _baseAuth;

  @override
  Future<int> createTask(
      List<Object> objects, Task task, UserType userType) async {
    final user = await _baseAuth.getCurrentUser();
    task.createdBy = user.clientId;
    task.assignee = user.clientId;
    debugPrint("Set user id: " + user.clientId.toString());
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
  Future<List<Task>> getTasksForUser(int lastTaskId, UserType userType) async {
    final user = await _baseAuth.getCurrentUser();
    this._user = user;
    debugPrint("Set user id: " + user.clientId.toString());
    return _httpTaskProvider.getTasksForCurrentUser(lastTaskId, user.clientId);
  }

  @override
  Future<bool> updateTask(Task task) {
    return _httpTaskProvider.updateTask(task);
  }

  @override
  void set baseAuth(BaseAuth _baseAuth) {
    _setHttpProvider();
  }

  Future<void> _setHttpProvider() async {
    final bearerAuth = await _getAuthToken();
    _httpTaskProvider = HttpTaskProvider(bearerAuth, logoutCallback);
  }

  Future<String> _getAuthToken() async {
    final user = await _baseAuth.getCurrentUser();
    debugPrint("User is: " + user.toString());
    this._auth = 'Bearer ' + user.token.toString();
    this._user = user;
    return 'Bearer ' + user.token.toString();
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
    return _httpTaskProvider.updateTaskWithAttachments(objects, task);
  }

  Future<bool> voteForTask(Task task, VoteChoice voteChoice) {
    return _httpTaskProvider.voteForTask(task, voteChoice, _user.clientId);
  }

  String getAuth() {
    return _auth;
  }

  int getUserId() {
    return _user.clientId;
  }
}
