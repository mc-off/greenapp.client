import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import 'package:greenapp/models/user.dart';
import 'package:http/http.dart' as http;

class HttpAuth {
  final SessionStorage storage = new SessionStorage();
  Future<User> _user;
  HttpAuth() {
    this._user = getFromCache();
  }

  Future<User> currentUser() {
    return _user;
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final http.Response response = await http.post(
      'https://reqres.in/api/login',
      headers: {
        'Content-type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      print(response.toString());
      User user = User.fromJson(json.decode(response.body));
      updateCacheAndUser(user);
      return user;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print(response.toString());
      throw Exception('Failed to sign in');
    }
  }

  Future<User> signUpWithEmailAndPassword(String email, String password) async {
    final http.Response response = await http.post(
      'https://reqres.in/api/register',
      headers: {
        'Content-type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      print(response.toString());
      User user = User.fromJson(json.decode(response.body));
      debugPrint("Sign up user = " + user.token);
      updateCacheAndUser(user);
      return user;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception
      print(response.toString());
      throw Exception('Failed to sign up');
    }
  }

  void updateCacheAndUser(User user) {
    updateCache(user);
    this._user = getFromCache();
  }

  void updateCache(User user) {
    storage.writeSession(user.toString());
  }

  Future<User> getFromCache() async {
    String readedSession = await storage.readSession();
    return User(token: readedSession);
  }
}

class SessionStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/session.txt');
  }

  Future<String> readSession() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> writeSession(String session) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$session');
  }
}
