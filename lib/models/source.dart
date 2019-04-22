import 'package:equatable/equatable.dart';

class Source extends Equatable{
  int id;
  String name;
  String photo;
  String description;
  String link;
  int followerCount;
  bool isFollowing;

  Source({this.id, this.name, this.photo, this.description, this.link, this.followerCount, this.isFollowing}): super([id, name, photo, description, link, followerCount, isFollowing]);

}