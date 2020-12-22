import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/models/user.dart';

abstract class BaseTaskProvider {
  VoidCallback logoutCallback;

  Future<List<Task>> getTasks(int lastTaskId);

  Future<List<Task>> getTasksNum(int lastTaskId, int amount);

  Future<List<Task>> getTasksForUser(int lastTaskId, UserType userType);

  Future<int> createTask(List<Object> objects, Task task, UserType userType);

  Future<Uint8List> getAttachment(int attachId);

  Future<Task> getTask(int id);

  Future<bool> updateTask(Task task);

  Future<bool> updateTaskWithAttachments(List<Object> objects, Task task);
}
