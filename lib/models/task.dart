import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';

class Task {
  const Task({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.status,
    @required this.coordinate,
    @required this.type,
    @required this.reward,
    @required this.assignee,
    @required this.dueDate,
    @required this.updated,
    @required this.createdBy,
    @required this.created,
  })  : assert(id != null, 'id must not be null'),
        assert(status != null, 'status must not be null'),
        assert(coordinate != null, 'isFeatured must not be null'),
        assert(reward != null, 'name must not be null');

  final int id;
  //null
  final String title;
  //null
  final String description;
  final TaskStatus status;
  final Coordinate coordinate;
  final TaskType type;
  final int reward;
  //null
  final int assignee;
  //null
  final int updated;
  //null
  final String dueDate;
  final int createdBy;
  final int created;

  @override
  String toString() => '$title (id=$id)';

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
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
  final int longitude;
  final int latitude;

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
