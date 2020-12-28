// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    amount: json['amount'] as int,
    createdBy: json['createdBy'] as String,
    description: json['description'] as String,
    attachmentIds:
        (json['attachmentIds'] as List)?.map((e) => e as int)?.toList(),
    type: _$enumDecodeNullable(_$ItemTypeEnumMap, json['type']),
    id: json['id'] as int,
    price: json['price'] as int,
    title: json['title'] as String,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('amount', instance.amount);
  writeNotNull('createdBy', instance.createdBy);
  writeNotNull('description', instance.description);
  writeNotNull('attachmentIds', instance.attachmentIds);
  writeNotNull('type', _$ItemTypeEnumMap[instance.type]);
  writeNotNull('id', instance.id);
  writeNotNull('price', instance.price);
  writeNotNull('title', instance.title);
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

const _$ItemTypeEnumMap = {
  ItemType.TECH: 'TECH',
  ItemType.SALE: 'SALE',
  ItemType.COUPON: 'COUPON',
  ItemType.OTHER: 'OTHER',
};
