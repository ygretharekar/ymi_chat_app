import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User{
  String email;
  String id;
  bool isActive;

  User(this.email, this.id,this.isActive);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromNamed({String email, String id, bool isActive})=>User(email, id, isActive);

  String get firstName=>email.split(" ")[0];
}