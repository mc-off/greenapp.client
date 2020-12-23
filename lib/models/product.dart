import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart';

enum ProductStatus { SOLD, AVAILABLE }

@JsonSerializable(includeIfNull: false)
class Product {
  int amount;
  int createdBy;
  int createdWhen;
  String description;
  String headerPhoto;
  int id;
  int lastUpdated;
  int price;
  ProductStatus status;
  String title;

  Product(
      {this.amount,
      this.createdBy,
      this.createdWhen,
      this.description,
      this.headerPhoto,
      this.id,
      this.lastUpdated,
      this.price,
      this.status,
      this.title});

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

class ProductDateTime {
  int date;
  int day;
  int hours;
  int minutes;
  int month;
  int nanos;
  int seconds;
  int time;
  int timezoneOffset;
  int year;
}
