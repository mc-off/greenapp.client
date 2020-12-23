import 'package:json_annotation/json_annotation.dart';
part 'profile.g.dart';

enum ProfileType { INDIVIDUAL, LEGAL }

@JsonSerializable(includeIfNull: false)
class Profile {
  int id;
  String login;
  String name;
  String surname;
  String description;
  ProfileType type;
  int attachmentId;

  Profile(
      {this.id,
      this.login,
      this.name,
      this.surname,
      this.description,
      this.type,
      this.attachmentId});

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
