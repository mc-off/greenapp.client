import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'item.g.dart';

enum ItemType { TECH, SALE, COUPON, OTHER }

@JsonSerializable(includeIfNull: false)
class Item {
  int amount;
  String createdBy;
  String description;
  List<int> attachmentIds;
  ItemType type;
  int id;
  int price;
  String title;

  Item(
      {this.amount,
      this.createdBy,
      this.description,
      this.attachmentIds,
      this.type,
      this.id,
      this.price,
      this.title});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
