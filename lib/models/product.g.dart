// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) {
  return Product(
    amount: json['amount'] as int,
    createdBy: json['createdBy'] as int,
    createdWhen: json['createdWhen'] as int,
    description: json['description'] as String,
    headerPhoto: json['headerPhoto'] as String,
    id: json['id'] as int,
    lastUpdated: json['lastUpdated'] as int,
    price: json['price'] as int,
    status: _$enumDecodeNullable(_$ProductStatusEnumMap, json['status']),
    title: json['title'] as String,
  );
}

Map<String, dynamic> _$ProductToJson(Product instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('amount', instance.amount);
  writeNotNull('createdBy', instance.createdBy);
  writeNotNull('createdWhen', instance.createdWhen);
  writeNotNull('description', instance.description);
  writeNotNull('headerPhoto', instance.headerPhoto);
  writeNotNull('id', instance.id);
  writeNotNull('lastUpdated', instance.lastUpdated);
  writeNotNull('price', instance.price);
  writeNotNull('status', _$ProductStatusEnumMap[instance.status]);
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

const _$ProductStatusEnumMap = {
  ProductStatus.SOLD: 'SOLD',
  ProductStatus.AVAILABLE: 'AVAILABLE',
};
