import 'package:equatable/equatable.dart';

class Source extends Equatable{
  int id;
  String name;
  String photo;
  String description;
  String link;
  int followerCount;
  bool isFollowing;
  String feedUrl;
  String category;
  String form;
  String content_rss;

  Source({this.id, this.name, this.photo, this.description, this.link, this.followerCount, this.isFollowing, this.feedUrl, this.category, this.form, this.content_rss}): super([id, name, photo, description, link, followerCount, isFollowing]);

  Source copyWith({bool isFollowing}) {
    return Source(
      id: this.id,
      name: this.name,
      photo: this.photo,
      description: this.description,
      link: this.link,
      followerCount: this.followerCount,
      feedUrl: this.feedUrl,
      category: this.category,
      form: this.form,
      content_rss: this.content_rss,
      isFollowing: isFollowing ?? this.isFollowing
    );

  }
}