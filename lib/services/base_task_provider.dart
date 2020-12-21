import 'package:greenapp/models/task.dart';

abstract class BaseTaskProvider {
  Future<List<Task>> getTasks(int id);

  Future<Task> getTask(int id);

  Future<bool> updateTask();

  Future<bool> createTask();
}
