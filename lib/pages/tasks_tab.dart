import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/product_row_item.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:greenapp/models/app_state_model.dart';

class TasksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text('Tasks'),
        ),
        FutureBuilder(
          future: _getTasks(),
          builder: (context, projectSnap) {
            var childCount = 0;
            if (projectSnap.connectionState != ConnectionState.done ||
                projectSnap.hasData == null)
              childCount = 1;
            else
              childCount = projectSnap.data.length;
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (projectSnap.connectionState != ConnectionState.done) {
                  //todo handle state
                  return CupertinoActivityIndicator(); //todo set progress bar
                }
                if (projectSnap.hasData == null) {
                  return Container();
                }
                return ProductRowItem(
                  index: index,
                  task: projectSnap.data[index],
                  lastItem: index == projectSnap.data.length - 1,
                );
              }, childCount: childCount),
            );
          },
        ),
      ],
    );
  }

  Future<Map> getWeather(String key, double lat, double lon) async {
    String apiUrl =
        'https://api.darksky.net/forecast/$key/$lat,$lon?lang=sk&units=si';
    http.Response response = await http.get(apiUrl);
    debugPrint(response.body.toString());
    return json.decode(response.body);
  }

  Future<List<User>> _getUsers() async {
    var data = await http
        .get("http://www.json-generator.com/api/json/get/cfwZmvEBbC?indent=2");

    var jsonData = json.decode(data.body);

    List<User> users = [];

    for (var u in jsonData) {
      User user =
          User(u["index"], u["about"], u["name"], u["email"], u["picture"]);

      users.add(user);
    }

    print(users.length);

    return users;
  }

  Future<List<Task>> _getTasks() async {
    var uri = Uri.https(
        'greenapp-task-provider.herokuapp.com', '/task-provider/tasks');
    http.Response response = await http.post(
      "https://greenapp-task-provider.herokuapp.com/task-provider/tasks",
      headers: <String, String>{
        'Content-type': 'application/json',
        'X-GREEN-APP-ID': 'GREEN',
      },
      body: json.encode({
        'status': EnumToString.parse(TaskStatus.CREATED),
      }),
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
}

class DetailPage extends StatelessWidget {
  final Task task;

  DetailPage(this.task);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: Text(task.title),
    ));
  }
}

class User {
  final int index;
  final String about;
  final String name;
  final String email;
  final String picture;

  User(this.index, this.about, this.name, this.email, this.picture);
}
