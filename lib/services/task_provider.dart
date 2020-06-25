import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/services/base_auth.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/services/http_task_provider.dart';

class TaskProvider implements BaseTaskProvider {
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
  Future<bool> createTask() {
    // TODO: implement createTask
    throw UnimplementedError();
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
  Future<List<Task>> getTasksForUser(int lastTaskId, int userId) {
    return _httpTaskProvider.getTasksForCurrentUser(lastTaskId, userId);
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
    return 'Bearer ' + user.token.toString();
  }

  @override
  Future<List<Task>> getTasksNum(int lastTaskId, int amount) {
    return _httpTaskProvider.getTasksAmount(lastTaskId, amount);
  }

//  @override
//  Future<Image> getTaskAttachments(int taskId) {
//    return _httpTaskProvider.getAttachmentsForTask(taskId);
//  }
}
