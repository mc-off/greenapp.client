import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';

abstract class BaseTaskProvider {
  VoidCallback logoutCallback;

  Future<List<Task>> getTaskList(int lastTaskId, TaskStatus taskStatus,
      String searchString, String assignee, int amount);

  Future<int> createTask(List<Object> objects, Task task);

  Future<NetworkImage> getAttachment(int attachId);

  Future<Task> getTask(int id);

  Future<bool> updateTask(Task task);

  Future<bool> updateTaskWithAttachments(List<Object> objects, Task task);

  Future<bool> voteForTask(Task task, VoteChoice voteChoice);

  Future<bool> patchTaskStatus(Task task, TaskStatus taskStatus);

  String getToken();

  String getUserId();
}
