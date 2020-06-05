import 'package:enum_to_string/enum_to_string.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

List<Task> modelUserFromJson(String str) =>
    List<Task>.from(json.decode(str).map((x) => Task.fromJson(x)));

class Task {
  int id;

  //null
  String title;

  //null
  String description;
  TaskStatus status;
  Coordinate coordinate;
  TaskType type;
  int reward;

  //null
  int assignee;

  //null
  int updated;

  //null
  String dueDate;
  int createdBy;
  int created;

  Task(
      {this.id,
      this.title,
      this.description,
      this.status,
      this.coordinate,
      this.type,
      this.reward,
      this.assignee,
      this.updated,
      this.dueDate,
      this.createdBy,
      this.created});

  @override
  String toString() => '$title (id=$id)';

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['title'],
        status: EnumToString.fromString(TaskStatus.values, json['status']),
        coordinate: Coordinate.fromJson(json['coordinate']),
        type: EnumToString.fromString(TaskType.values, json['type']),
        reward: json['reward'],
        assignee: json['assignee'],
        updated: json['updated'],
        dueDate: json['dueDate'],
        createdBy: json['createdBy'],
        created: json['created'],
      );
}

enum TaskStatus {
  TRASHED,
  CREATED,
  WAITING_FOR_APPROVE,
  APPROVED,
  TO_DO,
  IN_PROGRESS,
  RESOLVED,
  COMPLETED
}

enum TaskType { ANIMAL, PEOPLE, ENVIRONMENT, PLANT, URBAN, OTHER }

class Coordinate {
  double longitude;
  double latitude;

  Coordinate({this.longitude, this.latitude});

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }

  @override
  String toString() => 'Longitude: $longitude, latitude = $latitude)';
}
