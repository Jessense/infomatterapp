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

  Source copyWith({bool isFollowing}) {
    return Source(
      id: this.id,
      name: this.name,
      photo: this.photo,
      description: this.description,
      link: this.link,
      followerCount: this.followerCount,
      isFollowing: isFollowing ?? this.isFollowing
    );

  }
}