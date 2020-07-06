import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import 'package:greenapp/models/user.dart';
import 'package:http/http.dart' as http;

class HttpAuth {
  final SessionStorage storage = new SessionStorage();
  Future<User> _user;
  static final String username = 'greenuser';
  static final String password = 'greenpassword';
  static final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  HttpAuth() {
    this._user = getFromCache();
  }

  Future<User> currentUser() {
    return _user;
  }

  Future<void> signOut() {
    clearCache();
    _user = getFromCache();
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final http.Response response = await http.post(
      'https://greenapp-gateway.herokuapp.com/authenticate',
      headers: {
        'Content-type': 'application/json',
      },
      body: json.encode({
        'username': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      print(response.body.toString());
      User user = User.fromJson(json.decode(response.body));
      debugPrint(user.toJson().toString());
      updateCacheAndUser(user);
      return user;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to sign in');
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

  void updateCacheAndUser(User user) {
    updateCache(user);
    this._user = getFromCache();
  }

  void updateCache(User user) {
    storage.writeSession(user);
  }

  Future<User> getFromCache() async {
    final readedSession = await storage.readSession();
    return readedSession;
  }

  Future<void> clearCache() async {
    await storage.deleteSession();
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

  Future<User> readSession() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      debugPrint('Contentents is ' + contents);

      return User.fromJson(json.decode(contents));
    } catch (e) {
      // If encountering an error, return 0
      return User(clientId: null, token: "");
    }
  }

  Future<File> writeSession(User session) async {
    final file = await _localFile;

    // Write the file
    debugPrint("Save file as ${json.encode(session)}");
    return file.writeAsString('${json.encode(session)}');
  }

  Future<File> deleteSession() async {
    final file = await _localFile;

    // Write the file
    return file.delete();
  }
}
