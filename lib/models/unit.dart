import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

@JsonSerializable(nullable: false)
class Unit {
  final String title;
  final String description;
  final int price;
  final int createdBy;

  Unit({this.title, this.description, this.price, this.createdBy});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
        title: json['title'],
        description: json['description'],
        price: json['price'],
        createdBy: json['createdBy']);
  }

  Map<String, dynamic> toJson() => _$UnitToJson(this);

  @override
  String toString() {
    return "$title";
  }
}
