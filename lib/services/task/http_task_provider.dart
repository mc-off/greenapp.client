import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:greenapp/models/task.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:image_jpeg/image_jpeg.dart';
import 'package:path/path.dart';

import 'package:google_map_location_picker/google_map_location_picker.dart'
    as location_picker;

import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;

class HttpTaskProvider {
  final VoidCallback logoutCallback;

  final fullTaskUrl = "https://alter-eco-api.herokuapp.com/api/";

  final taskUrl = "alter-eco-api.herokuapp.com";

  final taskPostfix = "/api";

  HttpTaskProvider(this.logoutCallback);

  Future<int> createTask(List<Object> objects, Task task) async {
    var uri = Uri.https(taskUrl, taskPostfix + '/task');

    debugPrint('Create: ' + json.encode(task));

    final dio.Dio dioClient = new dio.Dio();
    dioClient.options.headers["Authorization"] = _getCurrentToken();
    //dioClient.options.contentType = "multipart/form-data";
    debugPrint("Object amount: " + objects.length.toString());
    List<File> fileList = new List<File>();
    for (Object object in objects) {
      if (object is File && object != null) {
        fileList.add(object);
      }
    }
    debugPrint("Object amount (files): " + fileList.length.toString());
    var formData = dio.FormData();
    formData.files.add(MapEntry(
        'task',
        new dio.MultipartFile.fromString(json.encode(task),
            contentType: MediaType('application', 'json'))));
    for (File file in fileList) {
      final image = Image.file(file);
      String newFileName =
          await ImageJpeg.encodeJpeg(file.path, null, 70, 1600, 900);
      formData.files.add(MapEntry(
          "attachment",
          await dio.MultipartFile.fromFile(newFileName,
              filename: basename(file.path),
              contentType: MediaType.parse("image/jpeg"))));
    }

    debugPrint(formData.files.length.toString());
    if (formData.files.length > 1) {
      debugPrint(formData.files.last.key);

      debugPrint(formData.files.last.value.contentType.type);
      debugPrint(formData.files.last.value.contentType.subtype);
      debugPrint(formData.files.last.value.filename);
      debugPrint(formData.files.last.value.length.toString());
    }

    final response = await dioClient.postUri(uri, data: formData);

    if (response.statusCode == 200) {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint('Update success');
      return int.parse(response.data.toString());
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint(response.headers.map.toString());
      debugPrint(response.statusMessage);
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to update task ${task.toString()}');
    }
  }

  Future<bool> updateTaskWithAttachments(
      List<Object> objects, Task task) async {
    var queryParameters = {
      'detach': false.toString(),
    };
    var uri = Uri.https(taskUrl, taskPostfix + '/task', queryParameters);

    debugPrint('Update task: ' + json.encode(task));

    final dio.Dio dioClient = new dio.Dio();
    dioClient.options.headers["Authorization"] = _getCurrentToken();
    //dioClient.options.contentType = "multipart/form-data";
    debugPrint("Object amount: " + objects.length.toString());
    List<File> fileList = new List<File>();
    for (Object object in objects) {
      if (object is File && object != null) {
        fileList.add(object);
      }
    }
    debugPrint("Object amount (files): " + fileList.length.toString());
    var formData = dio.FormData();
    formData.files.add(MapEntry(
        'task',
        new dio.MultipartFile.fromString(json.encode(task),
            contentType: MediaType('application', 'json'))));
    for (File file in fileList) {
      String newFileName =
          await ImageJpeg.encodeJpeg(file.path, null, 70, 1600, 900);
      formData.files.add(MapEntry(
          "attachment",
          await dio.MultipartFile.fromFile(newFileName,
              filename: basename(file.path),
              contentType: MediaType.parse("image/jpeg"))));
    }

    final response = await dioClient.putUri(uri, data: formData);

    if (response.statusCode == 200) {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint('Update success');
      return true;
    } else {
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      debugPrint(response.headers.map.toString());
      debugPrint(response.statusMessage);
      if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to update task ${task.toString()}');
    }
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
  Future<List<Task>> _getTaskListWithoutStatus(
      int lastTaskId, String searchString, String assignee, int amount) async {
    debugPrint("getTasksList");
    debugPrint("lastTaskId " + lastTaskId.toString());
    Map body = ({
      "limit": amount,
      "offset": lastTaskId,
      "searchString": searchString,
      "sort": ['CREATED_DESC']
    });
    if (assignee != null && assignee.isNotEmpty) {
      body.addAll(({"assignee": assignee}));
    }
    final headers = <String, String>{
      'Authorization': await _getCurrentToken(),
      'Content-type': 'application/json',
    };
    debugPrint(body.toString());
    http.Response response = await http.post(
      fullTaskUrl + "/tasks",
      headers: headers,
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
        debugPrint(i.toString());
        taskList.add(Task.fromJson(i));
      }
      debugPrint(EnumToString.parse(taskList.first.status));
      return taskList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      //if (response.statusCode == 401) logoutCallback();
      throw Exception('Failed to parse tasks');
    }
  }

  Future<List<Task>> getTaskList(int lastTaskId, TaskStatus taskStatus,
      String searchString, String assignee, int amount) async {
    debugPrint("getTasksList");
    debugPrint("lastTaskId " + lastTaskId.toString());
    Map body = ({
      'status': EnumToString.parse(taskStatus),
      "limit": amount,
      "offset": lastTaskId,
      "searchString": searchString,
      "sort": ['CREATED_DESC']
    });
    if (assignee != null && assignee.isNotEmpty) {
      body.addAll(({"assignee": assignee}));
    }
    final headers = <String, String>{
      'Authorization': await _getCurrentToken(),
      'Content-type': 'application/json',
    };
    debugPrint(body.toString());
    http.Response response = await http.post(
      fullTaskUrl + "/tasks",
      headers: headers,
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
        debugPrint(i.toString());
        taskList.add(Task.fromJson(i));
      }
      try {
        debugPrint(EnumToString.parse(taskList.first.status));
      } catch (e) {}
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
    var uri = Uri.https(taskUrl, taskPostfix + '/task', queryParameters);

    //task.assignee = 'ybhM9WhJfXQJ5tMmDWGJRhZyk272';

    debugPrint('Update: ' + json.encode(task));

    final dio.Dio dioClient = new dio.Dio();
    var formData = dio.FormData();
    formData.files.add(MapEntry(
        'task',
        new dio.MultipartFile.fromString(json.encode(task),
            contentType: MediaType('application', 'json'))));
    dioClient.options.headers["Authorization"] = _getCurrentToken();
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
      fullTaskUrl + "/task/$id",
      headers: <String, String>{
        'Authorization': await _getCurrentToken(),
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint("Task getted");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      debugPrint(t.toString());

      Task task = Task.fromJson(jsonDecode(response.body));
      final coordinates =
          new Coordinates(task.coordinate.latitude, task.coordinate.longitude);
      try {
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var first = addresses.first;
        task.address = first.locality != null
            ? first.featureName + ' ' + first.locality
            : first.featureName;
      } catch (e) {}
      return task;
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

  Future<NetworkImage> getAttachment(int id) async {
    final t =
        NetworkImage(fullTaskUrl + "/attachment/$id", headers: <String, String>{
      'Authorization': await _getCurrentToken(),
    });
    return t;
  }

  Future<bool> patchTaskStatus(Task task, TaskStatus taskStatus) async {
    var queryParameters = {'status': EnumToString.convertToString(taskStatus)};
    var uri = Uri.https(
        taskUrl, taskPostfix + '/task/' + task.id.toString(), queryParameters);

    final dio.Dio dioClient = new dio.Dio();
    dioClient.options.headers["Authorization"] = _getCurrentToken();
    final dio.Response response = await dioClient.patchUri(uri);
    if (response.statusCode == 200) {
      debugPrint(response.statusCode.toString());
      debugPrint('Update success');
      return true;
    } else {
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 401) logoutCallback();
      //throw Exception('Failed to update task ${task.toString()}');
      return false;
    }
  }

  Future<bool> voteForTask(Task task, VoteChoice voteChoice) async {
    var queryParameters = {
      'taskId': task.id.toString(),
      'type': EnumToString.convertToString(voteChoice)
    };
    var uri = Uri.https(taskUrl, taskPostfix + '/vote', queryParameters);

    final dio.Dio dioClient = new dio.Dio();
    dioClient.options.headers["Authorization"] = _getCurrentToken();
    final dio.Response response = await dioClient.postUri(uri);
    if (response.statusCode == 200) {
      debugPrint(response.statusCode.toString());
      debugPrint('Update success');
      return true;
    } else {
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 401) logoutCallback();
      //throw Exception('Failed to update task ${task.toString()}');
      return false;
    }
  }

  Future<String> _getCurrentToken() async {
    final token = await _auth.currentUser.getIdToken(false);
    final token2 = await _auth.currentUser.getIdTokenResult();
    debugPrint('Bearer ' + token);
    return token != null ? 'Bearer ' + token : '';
  }
}
