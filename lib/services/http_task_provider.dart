import 'dart:convert';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';

import 'package:http/http.dart' as http;

class HttpTaskProvider {
  final String _bearerAuth;

  HttpTaskProvider(this._bearerAuth);

  Future<List<Task>> getCreatedTaskList(int lastTaskId) async {
    return getTaskList(lastTaskId, TaskStatus.CREATED, "", null);
  }

  Future<List<Task>> getTasksForCurrentUser(int lastTaskId, int userId) async {
    return getTaskList(lastTaskId, TaskStatus.CREATED, "", userId);
  }

  Future<List<Task>> getTaskList(int lastTaskId, TaskStatus taskStatus,
      String searchString, int assignee) async {
    debugPrint("getTasksList");
    debugPrint(_bearerAuth);
    Map body = ({
      'status': EnumToString.parse(taskStatus),
      "limit": 10,
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
      throw Exception('Failed to parse tasks');
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password,
      String firstName, String lastName, String birthDate) async {
    final http.Response response = await http.post(
      'https://greenapp-gateway.herokuapp.com/auth/sign/up',
      headers: <String, String>{
        'Content-type': 'application/json',
      },
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate,
        'mailAddress': email,
        'password': password
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      print(response.statusCode);
      print(response.body);
      return true;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to sign up');
    }
  }

  Future<bool> sendEmailVerification(String email, String code) async {
    final http.Response response = await http.post(
      'https://greenapp-gateway.herokuapp.com/auth/verify2fa',
      headers: <String, String>{
        'Content-type': 'application/json',
      },
      body: json.encode({'mailAddress': email, 'twoFaCode': int.parse(code)}),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      debugPrint("User validated");
      return true;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      throw Exception('Failed to validate user');
    }
  }

  Future<bool> resendEmailVerification(String email) async {
    var queryParameters = {
      'mail': email,
    };
    var uri = Uri.https(
        'greenapp-gateway.herokuapp.com', '/auth/resend2fa', queryParameters);
    final http.Response response = await http.get(
      uri,
      headers: <String, String>{
        'Content-type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      debugPrint("Code sended to $email");
      return true;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      throw Exception('Failed to resend code to $email');
    }
  }
}
