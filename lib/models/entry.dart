import 'package:equatable/equatable.dart';

class Entry extends Equatable {
  final int id;
  final String title;
  final String link;
  String digest;
  String pubDate;
  int form;
  String sourcePhoto;
  List<String> photo;
  int sourceId;
  String sourceName;

  bool isStarring;

  //optional
  int starId;

  Entry({this.id, this.title, this.link, this.digest, this.pubDate, this.form, this.sourcePhoto, this.photo, this.sourceId, this.sourceName, this.starId, this.isStarring}) : super([id, title, link, digest, pubDate, form, sourcePhoto, photo, sourceId, sourceName]);

  @override
  String toString() => 'Entry { id: $id }';
}