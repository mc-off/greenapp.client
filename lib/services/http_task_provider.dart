import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:greenapp/models/task.dart';
import 'package:http_parser/src/media_type.dart';

import 'package:http/http.dart' as http;

class HttpTaskProvider {
  final String _bearerAuth;
  final VoidCallback logoutCallback;

  HttpTaskProvider(this._bearerAuth, this.logoutCallback);

  Future<List<Task>> getCreatedTaskList(int lastTaskId) async {
    return _getTaskList(lastTaskId, TaskStatus.CREATED, "", null, 10);
  }

  Future<List<Task>> getTasksForCurrentUser(int lastTaskId, int userId) async {
    return _getTaskList(lastTaskId, TaskStatus.CREATED, "", userId, 10);
  }

  Future<List<Task>> getTasksAmount(int lastTaskId, int amount) async {
    return _getTaskList(lastTaskId, TaskStatus.CREATED, "", null, amount);
  }

//  Future<Image> getAttachmentsForTask(int id) async {
//    var uri = Uri.https(
//        'greenapp-gateway.herokuapp.com', '/task-provider/task/$id/attachment');
//
//    dio.Dio dioRequest = dio.Dio();
//
//    dioRequest.options.headers["Authorization"] = _bearerAuth;
//
//    dio.Response<dio.FormData> dioResponse = await dioRequest.get(
//        "https://greenapp-gatexway.herokuapp.com/task-provider/task/560633/attachment");
//
//    debugPrint("Status is " + dioResponse.statusCode.toString());
//
//    if (dioResponse.statusCode == 200) {
//      // If the server did return a 201 CREATED response,
//      // then parse the JSON.
//      debugPrint(dioResponse.data.toString());
//      List<Image> images;
//
//      dioResponse.data.files.forEach((element) async {
//        debugPrint(element.key);
//        debugPrint(element.value.filename);
//        debugPrint(element.value.length.toString());
//        io.File _transferedImage =
//            io.File('image'); // must assign a File to _transferedImage
//        io.IOSink sink = _transferedImage.openWrite();
//        await sink.addStream(element.value
//            .finalize()); // this requires await as addStream is async
//        await sink.close().then((value) {
//          images.add(Image.file(_transferedImage));
//        });
//        return images[0];
//      });
//    } else {
//      // If the server did no
//      //t return a 201 CREATED response,
//      // then throw an exception
//      debugPrint(dioResponse.statusCode.toString());
//      debugPrint(dioResponse.data.toString());
//      throw Exception('Failed to parse tasks');
//    }
//  }

  Future<List<Task>> _getTaskList(int lastTaskId, TaskStatus taskStatus,
      String searchString, int assignee, int amount) async {
    debugPrint("getTasksList");
    debugPrint(_bearerAuth);
    Map body = ({
      'status': EnumToString.parse(taskStatus),
      "limit": amount,
      "offset": lastTaskId,
      "searchString": searchString,
    });
    if (assignee != null) {
      body.addAll(({"assignee": assignee}));
    }
    http.Response response = await http.post(
      "https://greenapp-gateway.herokuapp.com/task-provider/tasks",
      headers: <String, String>{
        'Authorization': _bearerAuth,
        'Content-type': 'application/json',
      },
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      List<Task> taskList = [];
      for (Map i in t) {
        taskList.add(Task.fromJson(i));
      }
      return taskList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to parse tasks');
    }
  }

  Future<bool> updateTask(Task task) async {
    var queryParameters = {
      'detach': true.toString(),
    };
    var uri = Uri.https('greenapp-gateway.herokuapp.com', '/task-provider/task',
        queryParameters);

    task.assignee = 1;

    debugPrint('Update: ' + json.encode(task));

    final dio.Dio dioClient = new dio.Dio();
    var formData = dio.FormData();
    formData.files.add(MapEntry(
        'task',
        new dio.MultipartFile.fromString(json.encode(task),
            contentType: MediaType('application', 'json'))));
    dioClient.options.headers["Authorization"] = _bearerAuth;
    final dio.Response response = await dioClient.putUri(uri, data: formData);
    if (response.statusCode == 200) {
      debugPrint(response.statusCode.toString());
      debugPrint('Update success');
      return true;
    } else {
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to update task ${task.toString()}');
    }
  }

  Future<Task> getTask(int id) async {
    http.Response response = await http.get(
      "https://greenapp-gateway.herokuapp.com/task-provider/task/$id",
      headers: <String, String>{
        'Authorization': _bearerAuth,
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      return Task.fromJson(t);
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to parse tasks');
    }
  }
}
