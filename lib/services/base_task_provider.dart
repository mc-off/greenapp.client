import 'package:greenapp/models/task.dart';
import 'package:greenapp/services/base_auth.dart';

abstract class BaseTaskProvider {
  Future<List<Task>> getTasks();

  Future<Task> getTask(int id);

  Future<bool> updateTask();

  Future<bool> createTask();
}
