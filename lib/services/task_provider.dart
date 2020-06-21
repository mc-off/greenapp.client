import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/services/base_auth.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/services/http_task_provider.dart';

class TaskProvider implements BaseTaskProvider {
  BaseAuth _baseAuth;
  HttpTaskProvider _httpTaskProvider;

  TaskProvider(this._baseAuth) {
    this._baseAuth = _baseAuth;
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
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasks(int id) {
    return _httpTaskProvider.getTasksList(id);
  }

  @override
  Future<bool> updateTask() {
    // TODO: implement updateTask
    throw UnimplementedError();
  }

  @override
  void set baseAuth(BaseAuth _baseAuth) {
    _setHttpProvider();
  }

  Future<void> _setHttpProvider() async {
    final bearerAuth = await _getAuthToken();
    _httpTaskProvider = HttpTaskProvider(bearerAuth);
  }

  Future<String> _getAuthToken() async {
    final user = await _baseAuth.getCurrentUser();
    debugPrint("User is: " + user.toString());
    return 'Bearer ' + user.token.toString();
  }
}
