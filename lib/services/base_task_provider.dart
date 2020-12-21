import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';

abstract class BaseTaskProvider {
  VoidCallback logoutCallback;

  Future<List<Task>> getTasks(int lastTaskId);

  Future<List<Task>> getTasksNum(int lastTaskId, int amount);

  Future<List<Task>> getTasksForUser(int lastTaskId, int userId);

  //Future<Image> getTaskAttachments(int taskId);

  Future<Task> getTask(int id);

  Future<bool> updateTask(Task task);

  Future<bool> createTask();
}
