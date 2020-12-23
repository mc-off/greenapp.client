import 'package:built_value/built_value.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserType { LOCAL, OTHER }

@JsonSerializable(nullable: false)
class User {
  @JsonKey(name: 'jwttoken')
  final String token;
  final int clientId;

  User({this.token, this.clientId});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

//  factory User.fromJson(Map<String, dynamic> json) {
//    return User(
//      token: json['jwttoken'],
//    );
//  }

//  Map<String, dynamic> toJson() => {
//        'token': token,
//      };

  @override
  String toString() {
    return token;
  }
}
