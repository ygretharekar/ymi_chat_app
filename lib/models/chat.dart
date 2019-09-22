import 'package:json_annotation/json_annotation.dart';
import 'package:ymi_chat_app/models/user.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat{
  static const String TEXT="text";
  String type;
  dynamic content;
  User from, to;
  DateTime publishedAt;
  String groupId;
  Chat(this.content, this.from, this.to, this.publishedAt, this.type, this.groupId);

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  factory Chat.fromNamed({String content, User from, User to, DateTime publishedAt,String type=TEXT, String groupId = ""})=>Chat(content, from, to, publishedAt,type, groupId);

  Map<String, dynamic> toJson() => _$ChatToJson(this);
}