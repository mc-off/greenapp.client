// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) {
  return Unit(
    title: json['title'] as String,
    description: json['description'] as String,
    price: json['price'] as int,
    createdBy: json['createdBy'] as int,
  );
}

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'createdBy': instance.createdBy,
    };
