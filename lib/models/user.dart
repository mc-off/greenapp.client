import 'package:built_value/built_value.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(nullable: false)
class User {
  final String token;

  User({this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['jwttoken'],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
      };

  @override
  String toString() {
    return token;
  }
}
