import 'package:greenapp/models/task.dart';

abstract class BaseTaskProvider {
  Future<List<Task>> getTasks(int lastTaskId);

  Future<List<Task>> getTasksForUser(int lastTaskId, int userId);

  Future<Task> getTask(int id);

  Future<bool> updateTask();

  Future<bool> createTask();
}
