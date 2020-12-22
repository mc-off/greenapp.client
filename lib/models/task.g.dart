// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) {
  return Task(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    status: _$enumDecodeNullable(_$TaskStatusEnumMap, json['status']),
    coordinate: json['coordinate'] == null
        ? null
        : Coordinate.fromJson(json['coordinate'] as Map<String, dynamic>),
    type: _$enumDecodeNullable(_$TaskTypeEnumMap, json['type']),
    reward: json['reward'] as int,
    attachmentIds:
        (json['attachmentIds'] as List)?.map((e) => e as int)?.toList(),
    assignee: json['assignee'] as int,
    updated: json['updated'] as String,
    dueDate: json['dueDate'] as String,
    createdBy: json['createdBy'] as int,
    created: json['created'] as String,
  )..address = json['address'] as String;
}

Map<String, dynamic> _$TaskToJson(Task instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  writeNotNull('status', _$TaskStatusEnumMap[instance.status]);
  writeNotNull('coordinate', instance.coordinate);
  writeNotNull('type', _$TaskTypeEnumMap[instance.type]);
  writeNotNull('reward', instance.reward);
  writeNotNull('attachmentIds', instance.attachmentIds);
  writeNotNull('assignee', instance.assignee);
  writeNotNull('updated', instance.updated);
  writeNotNull('dueDate', instance.dueDate);
  writeNotNull('createdBy', instance.createdBy);
  writeNotNull('created', instance.created);
  writeNotNull('address', instance.address);
  return val;
}

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$TaskStatusEnumMap = {
  TaskStatus.TRASHED: 'TRASHED',
  TaskStatus.CREATED: 'CREATED',
  TaskStatus.WAITING_FOR_APPROVE: 'WAITING_FOR_APPROVE',
  TaskStatus.APPROVED: 'APPROVED',
  TaskStatus.TO_DO: 'TO_DO',
  TaskStatus.IN_PROGRESS: 'IN_PROGRESS',
  TaskStatus.RESOLVED: 'RESOLVED',
  TaskStatus.COMPLETED: 'COMPLETED',
};

const _$TaskTypeEnumMap = {
  TaskType.ANIMAL: 'ANIMAL',
  TaskType.PEOPLE: 'PEOPLE',
  TaskType.ENVIRONMENT: 'ENVIRONMENT',
  TaskType.PLANT: 'PLANT',
  TaskType.URBAN: 'URBAN',
  TaskType.OTHER: 'OTHER',
};

Coordinate _$CoordinateFromJson(Map<String, dynamic> json) {
  return Coordinate(
    longitude: (json['longitude'] as num)?.toDouble(),
    latitude: (json['latitude'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$CoordinateToJson(Coordinate instance) =>
    <String, dynamic>{
      'longitude': instance.longitude,
      'latitude': instance.latitude,
    };
